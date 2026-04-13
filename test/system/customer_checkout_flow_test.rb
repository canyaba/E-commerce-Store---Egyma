# frozen_string_literal: true

require 'application_system_test_case'

class CustomerCheckoutFlowTest < ApplicationSystemTestCase
  test 'customer signs in, checks out, and sees the order in account history' do
    sign_in_customer(users(:one))

    visit product_path(products(:one))
    fill_in 'Quantity', with: 2
    click_button 'Add to cart'

    assert_text "#{products(:one).title} added to cart."
    click_link 'Proceed to checkout'
    click_button 'Create order and continue to payment'

    assert_text 'Invoice and payment details'
    assert_text 'Payment status'

    visit orders_path

    assert_text 'Past orders'
    assert_text products(:one).title
  end

  test 'customer sees validation feedback when checkout details are incomplete' do
    users(:one).update!(
      first_name: nil,
      last_name: nil,
      address_line_1: nil,
      address_line_2: nil,
      city: nil,
      postal_code: nil,
      province: nil
    )

    sign_in_customer(users(:one))

    visit product_path(products(:one))
    fill_in 'Quantity', with: 1
    click_button 'Add to cart'
    click_link 'Proceed to checkout'
    click_button 'Create order and continue to payment'

    assert_text 'Please correct the following issues:'
    assert_text "First name can't be blank"
    assert_text "Province can't be blank"
  end

  private

  def sign_in_customer(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'Password123!'
    click_button 'Log in'

    assert_text "Signed in as #{user.email}"
  end
end
