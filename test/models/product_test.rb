# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'requires title description and price' do
    product = Product.new

    assert_not product.valid?
    assert_includes product.errors[:title], "can't be blank"
    assert_includes product.errors[:description], "can't be blank"
    assert_includes product.errors[:price], "can't be blank"
  end

  test 'requires active to be true or false when explicitly set' do
    product = products(:one)
    product.active = nil

    assert_not product.valid?
    assert_includes product.errors[:active], 'is not included in the list'
  end

  test 'requires non-negative price' do
    product = products(:one)
    product.price = -1

    assert_not product.valid?
    assert_includes product.errors[:price], 'must be greater than or equal to 0'
  end

  test 'can have many categories through product categories' do
    assert_includes products(:one).categories, categories(:one)
  end

  test 'title must be unique' do
    duplicate = Product.new(
      title: products(:one).title,
      description: 'Different description',
      price: 25,
      active: true
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:title], 'has already been taken'
  end
end
