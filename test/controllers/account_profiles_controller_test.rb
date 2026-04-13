# frozen_string_literal: true

require 'test_helper'

class AccountProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'requires login before showing account details' do
    get account_url

    assert_redirected_to new_user_session_url
  end

  test 'shows saved account details for signed-in users' do
    sign_in users(:one)

    get account_url

    assert_response :success
    assert_select 'h1', 'Saved billing details'
    assert_select 'dd', /Jordan Member/
    assert_select 'dd', /Manitoba/
  end

  test 'updates saved address details with province' do
    sign_in users(:one)

    patch account_url, params: {
      user: {
        first_name: 'Jordan',
        last_name: 'Member',
        address_line_1: '500 Portage Avenue',
        address_line_2: 'Suite 100',
        city: 'Winnipeg',
        postal_code: 'R3B 2E9',
        province_id: provinces(:ontario).id
      }
    }

    assert_redirected_to account_url

    users(:one).reload
    assert_equal '500 Portage Avenue', users(:one).address_line_1
    assert_equal 'Ontario', users(:one).province.name
  end

  test 'renders errors when profile details are invalid' do
    sign_in users(:one)

    patch account_url, params: {
      user: {
        first_name: '',
        last_name: '',
        address_line_1: '',
        city: 'Winnipeg',
        postal_code: 'bad',
        province_id: ''
      }
    }

    assert_response :unprocessable_content
    assert_select '.alert-danger', /Please correct the following issues/i
    assert_select 'h1', 'Edit saved billing details'
  end

  test 'checkout prefills the saved account details after update' do
    sign_in users(:one)
    patch account_url, params: {
      user: {
        first_name: 'Avery',
        last_name: 'Client',
        address_line_1: '1 Lombard Place',
        address_line_2: '',
        city: 'Winnipeg',
        postal_code: 'R3B 0X3',
        province_id: provinces(:manitoba).id
      }
    }

    post cart_items_url, params: { product_id: products(:one).id, quantity: 1 }
    get checkout_url

    assert_response :success
    assert_select 'input[name="user[first_name]"][value="Avery"]'
    assert_select 'input[name="user[address_line_1]"][value="1 Lombard Place"]'
    assert_select 'input[name="user[postal_code]"][value="R3B 0X3"]'
    assert_select 'select[name="user[province_id]"] option[selected="selected"]', text: 'Manitoba'
  end
end
