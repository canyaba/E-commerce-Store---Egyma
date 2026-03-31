# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { 'Egyma Admin' } do
    columns do
      column do
        panel 'Catalog Overview' do
          ul do
            li "Products: #{Product.count}"
            li "Categories: #{Category.count}"
            li "Active products: #{Product.where(active: true).count}"
            li "Orders: #{Order.count}"
            li "Paid orders: #{Order.where(status: 'paid').count}"
          end
        end
      end

      column do
        panel 'Storefront Status' do
          para 'Use this dashboard to manage catalog data, province tax rates, and order fulfillment.'
          if controller.session[:admin_last_path].present?
            para "Last admin page visited: #{controller.session[:admin_last_path]}"
          end
        end
      end
    end
  end
end
