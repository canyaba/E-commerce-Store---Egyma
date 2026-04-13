# frozen_string_literal: true

ActiveAdmin.register Province do
  permit_params :name, :code, :gst_rate, :pst_rate, :hst_rate

  filter :name
  filter :code

  index do
    selectable_column
    id_column
    column :name
    column :code
    column('GST') { |province| tax_rate_label(province.gst_rate) }
    column('PST') { |province| tax_rate_label(province.pst_rate) }
    column('HST') { |province| tax_rate_label(province.hst_rate) }
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Province Tax Rates' do
      f.input :name
      f.input :code
      f.input :gst_rate
      f.input :pst_rate
      f.input :hst_rate
    end

    f.actions
  end

  controller do
    helper_method :tax_rate_label

    def tax_rate_label(rate)
      helpers.number_to_percentage(
        rate * 100,
        precision: 2,
        strip_insignificant_zeros: true
      )
    end
  end
end
