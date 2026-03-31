# frozen_string_literal: true

stripe_secret_key = ENV.fetch('STRIPE_SECRET_KEY', nil)
Stripe.api_key = stripe_secret_key if defined?(Stripe) && stripe_secret_key.present?
