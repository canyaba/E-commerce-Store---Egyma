# frozen_string_literal: true

module Orders
  class PricingPreview
    Result = Struct.new(
      :province,
      :subtotal,
      :gst_rate,
      :pst_rate,
      :hst_rate,
      :gst_amount,
      :pst_amount,
      :hst_amount,
      :tax_total,
      :total
    )

    def initialize(cart:, province:)
      @cart = cart
      @province = province
    end

    def call
      subtotal = decimal(@cart.subtotal)
      rates = province_rates
      amounts = tax_amounts(subtotal, rates)

      build_result(subtotal, rates, amounts)
    end

    private

    def province_rates
      {
        gst_rate: province_rate(:gst_rate),
        pst_rate: province_rate(:pst_rate),
        hst_rate: province_rate(:hst_rate)
      }
    end

    def province_rate(attribute)
      decimal(@province&.public_send(attribute) || 0)
    end

    # rubocop:disable Metrics/MethodLength
    def tax_amounts(subtotal, rates)
      gst_amount = money(subtotal * rates[:gst_rate])
      pst_amount = money(subtotal * rates[:pst_rate])
      hst_amount = money(subtotal * rates[:hst_rate])
      tax_total = money(gst_amount + pst_amount + hst_amount)

      {
        gst_amount: gst_amount,
        pst_amount: pst_amount,
        hst_amount: hst_amount,
        tax_total: tax_total,
        total: money(subtotal + tax_total)
      }
    end

    def build_result(subtotal, rates, amounts)
      Result.new(
        @province,
        money(subtotal),
        rates[:gst_rate],
        rates[:pst_rate],
        rates[:hst_rate],
        amounts[:gst_amount],
        amounts[:pst_amount],
        amounts[:hst_amount],
        amounts[:tax_total],
        amounts[:total]
      )
    end
    # rubocop:enable Metrics/MethodLength

    def decimal(value)
      BigDecimal(value.to_s)
    end

    def money(value)
      decimal(value).round(2)
    end
  end
end
