# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'shows the public catalog on the home page' do
    get root_url

    assert_response :success
    assert_select 'h1', /Structured training programs/
    assert_select 'article[data-testid="product-card"]', count: 6
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:one).title)}/
    assert_select 'article[data-testid="product-card"]', text: products(:nine).title, count: 0
    assert_select 'nav'
  end

  test 'paginates products on the home page' do
    get root_url(page: 2)

    assert_response :success
    assert_select 'article[data-testid="product-card"]', count: 2
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:two).title)}/
    assert_select 'article[data-testid="product-card"]', /#{Regexp.escape(products(:eight).title)}/
  end
end
