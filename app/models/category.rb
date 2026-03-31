# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  scope :alphabetical, -> { order(:name) }

  before_validation :generate_slug

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at description id name slug updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[product_categories products]
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
