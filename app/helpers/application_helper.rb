# frozen_string_literal: true

module ApplicationHelper
  def formatted_tax_rate(rate)
    number_to_percentage(rate.to_d * 100, precision: 2, strip_insignificant_zeros: true)
  end

  def order_status_badge_class(status)
    case status
    when 'paid'
      'text-bg-success'
    when 'shipped'
      'text-bg-primary'
    else
      'text-bg-secondary'
    end
  end
end
