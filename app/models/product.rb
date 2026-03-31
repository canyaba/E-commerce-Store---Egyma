# frozen_string_literal: true

class Product < ApplicationRecord
  has_one_attached :image

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  scope :catalog_order, -> { order(:title) }
  scope :active_catalog, -> { where(active: true).catalog_order }
  scope :keyword_search, lambda { |query|
    if query.present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(query.strip)
      where('products.title ILIKE :query OR products.description ILIKE :query', query: "%#{sanitized_query}%")
    else
      all
    end
  }
  scope :for_category, lambda { |category_id|
    if category_id.present?
      joins(:product_categories).where(product_categories: { category_id: category_id }).distinct
    else
      all
    end
  }

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }

  def self.ransackable_attributes(_auth_object = nil)
    %w[active created_at description id price title updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[categories product_categories]
  end
end
