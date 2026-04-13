# frozen_string_literal: true

require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test 'redirects guests away from order history' do
    get orders_url

    assert_redirected_to new_user_session_url
  end

  test 'lists the current user orders' do
    sign_in users(:one)

    get orders_url

    assert_response :success
    assert_select 'h1', /Past orders/i
    assert_select 'article', text: /Order ##{orders(:new_order).id}/
    assert_select 'article', text: /Order ##{orders(:paid_order).id}/
    assert_select 'article', text: /Order ##{orders(:other_user_order).id}/, count: 0
  end

  test 'shows a current user order invoice' do
    sign_in users(:one)

    get order_url(orders(:paid_order))

    assert_response :success
    assert_select 'nav[aria-label="Breadcrumb"]'
    assert_select 'h1', /Invoice and payment details/i
    assert_select 'td', text: /\$109\.76/
  end

  test 'does not allow access to another user order' do
    sign_in users(:one)

    get order_url(orders(:other_user_order))

    assert_response :not_found
  end

  test 'redirects guests away from order details' do
    get order_url(orders(:paid_order))

    assert_redirected_to new_user_session_url
  end
end
