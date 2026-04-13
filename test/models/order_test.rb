# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'requires a valid billing email format' do
    order = orders(:new_order)
    order.billing_email = 'not-an-email'

    assert_not order.valid?
    assert_includes order.errors[:billing_email], 'is invalid'
  end

  test 'mark_paid transitions from new to paid' do
    order = orders(:new_order)

    order.mark_paid!(reference: 'pi_test_123', processor: 'stripe')

    assert_equal 'paid', order.status
    assert_equal 'pi_test_123', order.payment_reference
    assert_equal 'stripe', order.payment_processor
    assert order.paid_at.present?
  end

  test 'does not allow shipping a new order' do
    order = orders(:new_order)

    assert_raises(Order::InvalidTransitionError) do
      order.mark_shipped!
    end
  end
end
