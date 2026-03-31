# frozen_string_literal: true

require 'test_helper'

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  test 'requires login before showing checkout' do
    get checkout_url

    assert_redirected_to new_user_session_url
  end

  test 'creates order snapshots from the current cart' do
    sign_in users(:one)
    post cart_items_url, params: { product_id: products(:one).id, quantity: 2 }

    assert_difference('Order.count', 1) do
      assert_difference('OrderItem.count', 1) do
        post checkout_url, params: {
          user: {
            first_name: 'Jordan',
            last_name: 'Member',
            address_line_1: '123 Main Street',
            address_line_2: 'Unit 5',
            city: 'Winnipeg',
            postal_code: 'R3C 0V1',
            province_id: provinces(:manitoba).id
          }
        }
      end
    end

    order = Order.order(:created_at).last

    assert_redirected_to order_url(order)
    assert_equal 'new', order.status
    assert_equal 'Manitoba', order.province_name
    assert_equal BigDecimal('158.00'), order.subtotal_amount
    assert_equal BigDecimal('176.96'), order.total_amount
    assert_equal 1, order.order_items.count
    assert_equal 2, order.order_items.first.quantity
  end

  test 'renders validation errors when address details are incomplete' do
    sign_in users(:one)
    post cart_items_url, params: { product_id: products(:one).id, quantity: 1 }

    assert_no_difference('Order.count') do
      post checkout_url, params: {
        user: {
          first_name: '',
          last_name: '',
          address_line_1: '',
          city: 'Winnipeg',
          postal_code: 'bad',
          province_id: ''
        }
      }
    end

    assert_response :unprocessable_content
    assert_select '.alert-danger', /Please correct the following issues/i
  end
end
