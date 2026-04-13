# frozen_string_literal: true

require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  test 'requires associated order and product' do
    order_item = OrderItem.new(product_title: 'Sample', quantity: 1, unit_price_amount: 10, line_total_amount: 10)

    assert_not order_item.valid?
    assert_includes order_item.errors[:order], 'must exist'
    assert_includes order_item.errors[:product], 'must exist'
  end
end
