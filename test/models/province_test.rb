# frozen_string_literal: true

require 'test_helper'

class ProvinceTest < ActiveSupport::TestCase
  test 'requires a two-character province code' do
    province = provinces(:manitoba)
    province.code = 'MAN'

    assert_not province.valid?
    assert_includes province.errors[:code], 'is the wrong length (should be 2 characters)'
  end

  test 'combines tax rates' do
    assert_equal BigDecimal('0.12'), provinces(:manitoba).combined_rate
  end
end
