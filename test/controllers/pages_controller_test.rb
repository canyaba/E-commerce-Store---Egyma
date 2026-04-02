# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'shows the about page' do
    get about_url

    assert_response :success
    assert_select 'h1', 'About Egyma'
    assert_select 'article', /Winnipeg-based digital fitness marketplace/i
  end

  test 'shows the contact page' do
    get contact_url

    assert_response :success
    assert_select 'h1', 'Contact Egyma'
    assert_select 'article', /support@egyma.local/i
  end

  test 'does not show unpublished pages' do
    get page_url(pages(:draft).slug)

    assert_response :not_found
  end
end
