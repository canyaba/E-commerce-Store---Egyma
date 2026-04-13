# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test 'filters category products to recently updated items' do
    age_all_products!(created_at: 60.days.ago, updated_at: 55.days.ago)
    set_product_timestamps!(products(:one), created_at: 45.days.ago, updated_at: 2.days.ago)

    get category_url(categories(:one), filter: 'recently_updated')

    assert_response :success
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:one).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:five).title, count: 0
    assert_select 'a.btn.btn-dark', text: 'Recently updated (last 3 days)'
  end

  test 'shows products for a category' do
    get category_url(categories(:one))

    assert_response :success
    assert_select 'h1', categories(:one).name
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:one).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:two).title, count: 0
  end
end
