# frozen_string_literal: true

require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  test 'requires a valid unique email address' do
    admin = AdminUser.new(email: 'bad-email', password: 'Password123!', password_confirmation: 'Password123!')

    assert_not admin.valid?
    assert_includes admin.errors[:email], 'is invalid'
  end
end
