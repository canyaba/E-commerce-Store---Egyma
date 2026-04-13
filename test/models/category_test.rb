# frozen_string_literal: true

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'requires name and slug' do
    category = Category.new

    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
    assert_includes category.errors[:slug], "can't be blank"
    assert_includes category.errors[:description], "can't be blank"
  end

  test 'generates slug from name when blank' do
    category = Category.new(name: 'Nutrition Templates', description: 'Meal planning')

    assert category.valid?
    assert_equal 'nutrition-templates', category.slug
  end

  test 'name must be unique' do
    duplicate = Category.new(name: categories(:one).name, slug: 'another-slug')

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], 'has already been taken'
  end

  test 'requires description' do
    category = categories(:one)
    category.description = ''

    assert_not category.valid?
    assert_includes category.errors[:description], "can't be blank"
  end
end
