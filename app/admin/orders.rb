# frozen_string_literal: true

ActiveAdmin.register Order do
  actions :all, except: %i[new create edit update destroy]

  includes :user, :province, :order_items

  filter :status, as: :select, collection: Order::STATUSES
  filter :billing_email
  filter :user
  filter :province
  filter :created_at

  action_item :mark_shipped, only: :show, if: proc { resource.shippable? } do
    link_to 'Mark shipped', mark_shipped_admin_order_path(resource), method: :put
  end

  member_action :mark_shipped, method: :put do
    resource.mark_shipped!
    redirect_to resource_path(resource), notice: 'Order marked as shipped.'
  rescue Order::InvalidTransitionError => e
    redirect_to resource_path(resource), alert: e.message
  end

  index do
    selectable_column
    id_column
    column :created_at
    column :user
    column :billing_email
    column :province_name
    column :status
    column(:total_amount) { |order| number_to_currency(order.total_amount) }
    actions defaults: true do |order|
      item('Ship', mark_shipped_admin_order_path(order), method: :put, class: 'member_link') if order.shippable?
    end
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :status
      row :user
      row :billing_email
      row :payment_processor
      row :payment_reference
      row :paid_at
      row :shipped_at
      row :province_name
      row(:subtotal_amount) { |order| number_to_currency(order.subtotal_amount) }
      row(:tax_total_amount) { |order| number_to_currency(order.tax_total_amount) }
      row(:total_amount) { |order| number_to_currency(order.total_amount) }
    end

    panel 'Line Items' do
      table_for resource.order_items do
        column :product_title
        column :quantity
        column(:unit_price_amount) { |item| number_to_currency(item.unit_price_amount) }
        column(:line_total_amount) { |item| number_to_currency(item.line_total_amount) }
      end
    end
  end
end
