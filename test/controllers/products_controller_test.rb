# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test 'shows a product detail page' do
    get product_url(products(:one))

    assert_response :success
    assert_select 'h1', products(:one).title
    assert_select 'p', text: /structured beginner lifting program/i
    assert_select 'a', text: categories(:one).name
  end

  test 'does not show inactive products' do
    get product_url(products(:nine))

    assert_response :not_found
  end
end
