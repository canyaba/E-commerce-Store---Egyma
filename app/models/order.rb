# frozen_string_literal: true

class Order < ApplicationRecord
  class InvalidTransitionError < StandardError; end

  STATUSES = %w[new paid shipped].freeze

  belongs_to :user
  belongs_to :province

  has_many :order_items, dependent: :destroy

  scope :recent_first, -> { order(created_at: :desc) }

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :billing_first_name, :billing_last_name, :billing_email, :address_line_1, :city, :postal_code,
            :province_name, :province_code, presence: true
  validates :subtotal_amount, :gst_amount, :pst_amount, :hst_amount, :tax_total_amount, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }
  validates :gst_rate, :pst_rate, :hst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      billing_email city created_at gst_amount gst_rate id paid_at payment_processor payment_reference
      postal_code province_id province_code province_name pst_amount pst_rate shipped_at status
      subtotal_amount tax_total_amount total_amount updated_at user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order_items province user]
  end

  def payable?
    status == 'new'
  end

  def paid?
    %w[paid shipped].include?(status)
  end

  def shippable?
    status == 'paid'
  end

  def shipped?
    status == 'shipped'
  end

  def mark_paid!(reference:, processor:)
    raise InvalidTransitionError, 'Only new orders can be marked paid.' unless payable?

    update!(
      status: 'paid',
      payment_reference: reference,
      payment_processor: processor,
      paid_at: Time.current
    )
  end

  def mark_shipped!
    raise InvalidTransitionError, 'Only paid orders can be marked shipped.' unless shippable?

    update!(status: 'shipped', shipped_at: Time.current)
  end
end
