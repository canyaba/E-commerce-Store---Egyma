# frozen_string_literal: true

require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_stripe_secret_key = ENV.fetch('STRIPE_SECRET_KEY', nil)
    ENV['STRIPE_SECRET_KEY'] = 'sk_test_123'
  end

  teardown do
    ENV['STRIPE_SECRET_KEY'] = @original_stripe_secret_key
  end

  test 'redirects to a Stripe checkout session for unpaid orders' do
    sign_in users(:one)

    fake_session = Struct.new(:url).new('https://checkout.stripe.test/session_123')
    fake_creator = Object.new
    fake_creator.define_singleton_method(:call) do |success_url:, cancel_url:|
      raise 'missing success_url' if success_url.blank?
      raise 'missing cancel_url' if cancel_url.blank?

      fake_session
    end

    Payments::StripeCheckoutSessionCreator.stub(:new, ->(*) { fake_creator }) do
      post order_payment_url(orders(:new_order))
    end

    assert_redirected_to 'https://checkout.stripe.test/session_123'
  end

  test 'shows an alert when Stripe test mode is not configured' do
    sign_in users(:one)
    ENV.delete('STRIPE_SECRET_KEY')

    post order_payment_url(orders(:new_order))

    assert_redirected_to order_url(orders(:new_order))
    follow_redirect!
    assert_match(/Stripe test mode is not configured\./i, response.body)
  end

  test 'marks an order paid after Stripe success callback' do
    sign_in users(:one)

    fake_session = Struct.new(:payment_status, :client_reference_id, :payment_intent, :id).new(
      'paid',
      orders(:new_order).id.to_s,
      'pi_test_123',
      'cs_test_123'
    )
    fake_verifier = Object.new
    fake_verifier.define_singleton_method(:call) do |session_id:|
      raise 'unexpected session id' unless session_id == 'cs_test_123'

      fake_session
    end

    Payments::StripeCheckoutSessionVerifier.stub(:new, ->(*) { fake_verifier }) do
      get payment_success_url(order_id: orders(:new_order).id, session_id: 'cs_test_123')
    end

    assert_redirected_to order_url(orders(:new_order))
    assert_equal 'paid', orders(:new_order).reload.status
    assert_equal 'pi_test_123', orders(:new_order).payment_reference
  end

  test 'keeps the order unpaid when Stripe does not confirm payment' do
    sign_in users(:one)

    fake_session = Struct.new(:payment_status, :client_reference_id, :payment_intent, :id).new(
      'unpaid',
      orders(:new_order).id.to_s,
      nil,
      'cs_test_456'
    )
    fake_verifier = Object.new
    fake_verifier.define_singleton_method(:call) do |session_id:|
      raise 'unexpected session id' unless session_id == 'cs_test_456'

      fake_session
    end

    Payments::StripeCheckoutSessionVerifier.stub(:new, ->(*) { fake_verifier }) do
      get payment_success_url(order_id: orders(:new_order).id, session_id: 'cs_test_456')
    end

    assert_redirected_to order_url(orders(:new_order))
    assert_equal 'new', orders(:new_order).reload.status
  end

  test 'admin can mark a paid order as shipped' do
    sign_in admin_users(:admin)

    put mark_shipped_admin_order_url(orders(:paid_order))

    assert_redirected_to admin_order_url(orders(:paid_order))
    assert_equal 'shipped', orders(:paid_order).reload.status
  end

  test 'admin cannot mark a new order as shipped' do
    sign_in admin_users(:admin)

    put mark_shipped_admin_order_url(orders(:new_order))

    assert_redirected_to admin_order_url(orders(:new_order))
    assert_equal 'new', orders(:new_order).reload.status
  end
end
