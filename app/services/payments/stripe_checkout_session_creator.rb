# frozen_string_literal: true

module Payments
  class StripeCheckoutSessionCreator
    class Error < StandardError; end

    def initialize(order:)
      @order = order
    end

    def call(success_url:, cancel_url:)
      Stripe.api_key = stripe_secret_key

      Stripe::Checkout::Session.create(session_payload(success_url: success_url, cancel_url: cancel_url))
    rescue Stripe::StripeError => e
      raise Error, e.message
    end

    private

    def stripe_secret_key
      ENV.fetch('STRIPE_SECRET_KEY', nil).presence || raise(Error, 'Stripe test mode is not configured.')
    end

    def session_payload(success_url:, cancel_url:)
      {
        mode: 'payment',
        success_url: success_url,
        cancel_url: cancel_url,
        client_reference_id: @order.id.to_s,
        customer_email: @order.billing_email,
        metadata: { order_id: @order.id },
        line_items: build_line_items
      }
    end

    def build_line_items
      line_items = @order.order_items.map { |item| product_line_item(item) }

      return line_items if @order.tax_total_amount.zero?

      line_items << tax_line_item

      line_items
    end

    def product_line_item(item)
      {
        quantity: item.quantity,
        price_data: {
          currency: 'cad',
          product_data: { name: item.product_title },
          unit_amount: cents_for(item.unit_price_amount)
        }
      }
    end

    def tax_line_item
      {
        quantity: 1,
        price_data: {
          currency: 'cad',
          product_data: { name: 'Provincial and federal sales tax' },
          unit_amount: cents_for(@order.tax_total_amount)
        }
      }
    end

    def cents_for(amount)
      (BigDecimal(amount.to_s) * 100).to_i
    end
  end
end
