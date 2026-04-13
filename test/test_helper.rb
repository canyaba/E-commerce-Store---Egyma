# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def set_product_timestamps!(product, created_at:, updated_at:)
      Product.record_timestamps = false
      product.update!(created_at: created_at, updated_at: updated_at)
    ensure
      Product.record_timestamps = true
    end

    def age_all_products!(created_at:, updated_at:)
      Product.find_each do |product|
        set_product_timestamps!(product, created_at: created_at, updated_at: updated_at)
      end
    end
  end
end

# rubocop:disable Style/OneClassPerFile
module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
# rubocop:enable Style/OneClassPerFile
