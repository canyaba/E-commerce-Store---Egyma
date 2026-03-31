# frozen_string_literal: true

require 'test_helper'

class CartsControllerTest < ActionDispatch::IntegrationTest
  test 'shows an empty cart by default' do
    get cart_url

    assert_response :success
    assert_select 'h2', /Your cart is empty/
  end

  test 'adds a product to the session cart' do
    post cart_items_url, params: { product_id: products(:one).id, quantity: 2 }

    assert_redirected_to cart_url
    follow_redirect!

    assert_select 'td', /#{Regexp.escape(products(:one).title)}/
    assert_select '.cart-quantity-field[value="2"]'
    assert_select 'a', /Cart \(2\)/
  end

  test 'updates cart quantity without removing the item' do
    post cart_items_url, params: { product_id: products(:one).id, quantity: 1 }
    patch cart_item_url(products(:one)), params: { quantity: 3 }

    assert_redirected_to cart_url
    follow_redirect!

    assert_select '.cart-quantity-field[value="3"]'
    assert_select 'a', /Cart \(3\)/
  end

  test 'removes an item from the cart with a dedicated remove action' do
    post cart_items_url, params: { product_id: products(:one).id, quantity: 1 }
    delete cart_item_url(products(:one))

    assert_redirected_to cart_url
    follow_redirect!

    assert_select 'h2', /Your cart is empty/
    assert_select 'a', /Cart \(0\)/
  end
end
