# frozen_string_literal: true

class ProductCategory < ApplicationRecord
  belongs_to :product
  belongs_to :category

  validates :product_id, uniqueness: { scope: :category_id }

  def self.ransackable_attributes(_auth_object = nil)
    %w[category_id created_at id product_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category product]
  end
end
