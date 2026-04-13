# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'searches by keyword across title and description' do
    get search_url(query: 'beginner')

    assert_response :success
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:one).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:two).title, count: 0
  end

  test 'filters search results by category' do
    get search_url(query: 'reset', category_id: categories(:two).id)

    assert_response :success
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:two).title)}/
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:four).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:one).title, count: 0
  end

  test 'filters search results to new products while preserving category search' do
    age_all_products!(created_at: 45.days.ago, updated_at: 40.days.ago)
    set_product_timestamps!(products(:two), created_at: 2.days.ago, updated_at: 1.day.ago)
    set_product_timestamps!(products(:four), created_at: 30.days.ago, updated_at: 29.days.ago)

    get search_url(query: 'reset', category_id: categories(:two).id, filter: 'new')

    assert_response :success
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:two).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:four).title, count: 0
    assert_select 'a.btn.btn-dark', text: 'New (last 3 days)'
  end
end
