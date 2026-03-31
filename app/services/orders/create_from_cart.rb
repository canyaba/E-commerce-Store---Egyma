# frozen_string_literal: true

module Orders
  class CreateFromCart
    class Error < StandardError; end

    def initialize(user:, cart:)
      @user = user
      @cart = cart
    end

    def call
      validate_checkout_state!
      pricing = pricing_preview

      ActiveRecord::Base.transaction do
        @user.save! if @user.changed?

        order = @user.orders.create!(order_attributes(pricing))
        build_order_items(order)
        order
      end
    rescue ActiveRecord::RecordInvalid => e
      raise Error, e.record.errors.full_messages.to_sentence
    end

    private

    def validate_checkout_state!
      raise Error, 'Your cart is empty.' if @cart.empty?
      raise Error, 'Complete your checkout details before placing the order.' unless @user.valid?(:checkout)
    end

    def pricing_preview
      Orders::PricingPreview.new(cart: @cart, province: @user.province).call
    end

    def order_attributes(pricing)
      {
        province: @user.province,
        status: 'new',
        **billing_attributes,
        **address_snapshot_attributes,
        **pricing_attributes(pricing)
      }
    end

    def billing_attributes
      {
        billing_first_name: @user.first_name,
        billing_last_name: @user.last_name,
        billing_email: @user.email
      }
    end

    def address_snapshot_attributes
      {
        address_line_1: @user.address_line_1,
        address_line_2: @user.address_line_2,
        city: @user.city,
        postal_code: @user.postal_code,
        province_name: @user.province.name,
        province_code: @user.province.code
      }
    end

    # rubocop:disable Metrics/MethodLength
    def pricing_attributes(pricing)
      {
        subtotal_amount: pricing.subtotal,
        gst_rate: pricing.gst_rate,
        pst_rate: pricing.pst_rate,
        hst_rate: pricing.hst_rate,
        gst_amount: pricing.gst_amount,
        pst_amount: pricing.pst_amount,
        hst_amount: pricing.hst_amount,
        tax_total_amount: pricing.tax_total,
        total_amount: pricing.total
      }
    end
    # rubocop:enable Metrics/MethodLength

    def build_order_items(order)
      @cart.items.each do |item|
        order.order_items.create!(
          product: item.product,
          product_title: item.product.title,
          quantity: item.quantity,
          unit_price_amount: item.product.price,
          line_total_amount: item.total_price
        )
      end
    end
  end
end
