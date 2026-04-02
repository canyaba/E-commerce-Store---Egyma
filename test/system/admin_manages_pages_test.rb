# frozen_string_literal: true

require 'application_system_test_case'

class AdminManagesPagesTest < ApplicationSystemTestCase
  setup do
    @admin = admin_users(:admin)
  end

  test 'admin updates the about page content' do
    updated_body = [
      'Egyma supports digital coaching products, structured training programs,',
      'and practical nutrition tools.'
    ].join(' ')

    visit new_admin_user_session_path
    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'Password123!'
    click_button 'Login'

    assert_text 'Dashboard'

    visit edit_admin_page_path(pages(:about).id)
    fill_in 'Body', with: updated_body
    click_button 'Update Page'

    assert_text 'Page updated successfully.'
    assert_text 'digital coaching products'
  end
end
