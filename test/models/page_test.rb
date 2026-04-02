# frozen_string_literal: true

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test 'requires title slug and body' do
    page = Page.new

    assert_not page.valid?
    assert_includes page.errors[:title], "can't be blank"
    assert_includes page.errors[:slug], "can't be blank"
    assert_includes page.errors[:body], "can't be blank"
  end

  test 'generates slug from title when blank' do
    page = Page.new(title: 'About Our Coaches', body: 'Some content', published: true)

    assert page.valid?
    assert_equal 'about-our-coaches', page.slug
  end

  test 'requires unique slug' do
    duplicate = Page.new(title: 'Another About', slug: pages(:about).slug, body: 'Different content', published: true)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], 'has already been taken'
  end
end
