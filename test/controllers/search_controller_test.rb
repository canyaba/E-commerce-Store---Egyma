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
end
