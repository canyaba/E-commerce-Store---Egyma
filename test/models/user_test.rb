# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'requires address details for the profile context' do
    user = users(:one)
    user.first_name = ''
    user.last_name = ''
    user.address_line_1 = ''
    user.postal_code = 'bad'
    user.province = nil

    assert_not user.valid?(:profile)
    assert_includes user.errors[:first_name], "can't be blank"
    assert_includes user.errors[:postal_code], 'must be a valid Canadian postal code'
    assert_includes user.errors[:province], "can't be blank"
  end

  test 'returns a combined full name' do
    assert_equal 'Jordan Member', users(:one).full_name
  end
end
