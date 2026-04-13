# frozen_string_literal: true

class Province < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :orders, dependent: :restrict_with_exception

  scope :alphabetical, -> { order(:name) }

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :code, length: { is: 2 }
  validates :gst_rate, :pst_rate, :hst_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[code created_at gst_rate hst_rate id name pst_rate updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[orders users]
  end

  def combined_rate
    gst_rate + pst_rate + hst_rate
  end
end
