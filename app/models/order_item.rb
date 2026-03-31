# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_title, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_amount, :line_total_amount, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id line_total_amount order_id product_id product_title quantity unit_price_amount updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order product]
  end
end
