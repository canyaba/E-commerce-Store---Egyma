# frozen_string_literal: true

module Payments
  class StripeCheckoutSessionVerifier
    class Error < StandardError; end

    def call(session_id:)
      Stripe.api_key = stripe_secret_key
      Stripe::Checkout::Session.retrieve(session_id)
    rescue Stripe::StripeError => e
      raise Error, e.message
    end

    private

    def stripe_secret_key
      ENV.fetch('STRIPE_SECRET_KEY', nil).presence || raise(Error, 'Stripe test mode is not configured.')
    end
  end
end
