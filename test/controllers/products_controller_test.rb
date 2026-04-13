# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test 'shows a product detail page' do
    products(:one).image.attach(
      io: file_fixture('sample-product.png').open,
      filename: 'sample-product.png',
      content_type: 'image/png'
    )

    get product_url(products(:one))

    assert_response :success
    assert_select 'nav[aria-label="Breadcrumb"]'
    assert_select '.breadcrumb-item', text: categories(:one).name
    assert_select 'h1', products(:one).title
    assert_select 'p', text: /structured beginner lifting program/i
    assert_select 'a', text: categories(:one).name
    assert_select 'img[width="960"][height="720"]'
  end

  test 'does not show inactive products' do
    get product_url(products(:nine))

    assert_response :not_found
  end
end
