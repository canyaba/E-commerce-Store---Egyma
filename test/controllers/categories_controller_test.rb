# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test 'shows products for a category' do
    get category_url(categories(:one))

    assert_response :success
    assert_select 'h1', categories(:one).name
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:one).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:two).title, count: 0
  end
end
