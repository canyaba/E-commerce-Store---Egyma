# frozen_string_literal: true

require 'application_system_test_case'

class AdminManagesProvincesTest < ApplicationSystemTestCase
  setup do
    @admin = admin_users(:admin)
    @province = provinces(:manitoba)
  end

  test 'admin views and updates province tax rates' do
    visit new_admin_user_session_path
    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'Password123!'
    click_button 'Login'

    assert_text 'Dashboard'

    visit admin_provinces_path
    assert_text @province.name

    click_link 'Edit', href: edit_admin_province_path(@province)
    fill_in 'province_gst_rate', with: '0.05'
    fill_in 'province_pst_rate', with: '0.08'
    fill_in 'province_hst_rate', with: '0.00'
    click_button 'Update Province'

    assert_text 'Province was successfully updated.'
    assert_text '0.08'
  end
end
