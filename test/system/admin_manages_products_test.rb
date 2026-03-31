# frozen_string_literal: true

require 'application_system_test_case'

class AdminManagesProductsTest < ApplicationSystemTestCase
  setup do
    @admin = admin_users(:admin)
  end

  test 'admin signs in creates a product and sees validation feedback' do
    visit new_admin_user_session_path
    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'Password123!'
    click_button 'Login'

    assert_text 'Dashboard'

    visit new_admin_product_path
    fill_in 'Title', with: 'Coach Starter Program'
    fill_in 'Description', with: 'A structured starter product for first-time Egyma customers.'
    fill_in 'Price', with: '49.00'
    check 'Strength Training'
    attach_file 'Image', Rails.root.join('test/fixtures/files/sample-product.svg')
    click_button 'Create Product'

    assert_text 'Product saved successfully.'
    assert_text 'Coach Starter Program'

    visit new_admin_product_path
    click_button 'Create Product'

    assert_text "can't be blank"
  end
end
