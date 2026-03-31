# frozen_string_literal: true

require 'test_helper'

class ProductCategoryTest < ActiveSupport::TestCase
  test 'prevents duplicate category assignment' do
    duplicate = ProductCategory.new(product: products(:one), category: categories(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_id], 'has already been taken'
  end
end
