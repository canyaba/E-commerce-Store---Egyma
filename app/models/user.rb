# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :province, optional: true

  has_many :orders, dependent: :restrict_with_exception, inverse_of: :user

  validates :first_name, :last_name, :address_line_1, :city, :postal_code, :province,
            presence: true,
            on: %i[checkout profile]
  validates :postal_code,
            format: {
              with: /\A[ABCEGHJ-NPRSTVXY]\d[A-Z][ -]?\d[A-Z]\d\z/i,
              message: 'must be a valid Canadian postal code'
            },
            allow_blank: true,
            on: %i[checkout profile]

  def self.ransackable_attributes(_auth_object = nil)
    %w[address_line_1 address_line_2 city created_at email first_name id last_name postal_code province_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[orders province]
  end

  def full_name
    [first_name, last_name].compact_blank.join(' ')
  end
end
