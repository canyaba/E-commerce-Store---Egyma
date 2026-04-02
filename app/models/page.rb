# frozen_string_literal: true

class Page < ApplicationRecord
  scope :published, -> { where(published: true) }

  before_validation :generate_slug

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true
  validates :published, inclusion: { in: [true, false] }

  def self.ransackable_attributes(_auth_object = nil)
    %w[body created_at id published slug title updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
