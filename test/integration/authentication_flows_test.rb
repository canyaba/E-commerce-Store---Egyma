# frozen_string_literal: true

require 'test_helper'

class AuthenticationFlowsTest < ActionDispatch::IntegrationTest
  test 'user can sign up' do
    assert_difference('User.count', 1) do
      post user_registration_url, params: {
        user: {
          email: 'newmember@example.com',
          password: 'Password123!',
          password_confirmation: 'Password123!'
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!

    assert_select 'span', /Signed in as newmember@example.com/
  end

  test 'registration errors are shown for invalid sign up' do
    assert_no_difference('User.count') do
      post user_registration_url, params: {
        user: {
          email: 'broken@example.com',
          password: 'Password123!',
          password_confirmation: 'Mismatch123!'
        }
      }
    end

    assert_response :unprocessable_content
    assert_select '.alert-danger', /Password confirmation/
  end

  test 'user can log in and log out' do
    post user_session_url, params: { user: { email: users(:one).email, password: 'Password123!' } }

    assert_redirected_to root_url
    follow_redirect!
    assert_select 'span', /Signed in as #{Regexp.escape(users(:one).email)}/

    delete destroy_user_session_url

    assert_redirected_to root_url
    follow_redirect!
    assert_select 'a', /Log in/
  end

  test 'invalid login keeps the user signed out' do
    post user_session_url, params: { user: { email: users(:one).email, password: 'WrongPassword123!' } }

    assert_response :unprocessable_content
    assert_select '.alert-danger', /Invalid email or password/
  end
end
