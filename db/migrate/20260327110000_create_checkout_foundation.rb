# frozen_string_literal: true

class CreateCheckoutFoundation < ActiveRecord::Migration[7.1]
  def change
    create_table :provinces do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :gst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :pst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :hst_rate, precision: 5, scale: 4, null: false, default: 0
      t.timestamps
    end

    add_index :provinces, :name, unique: true
    add_index :provinces, :code, unique: true

    change_table :users, bulk: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :postal_code
      t.references :province, foreign_key: true
    end

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :province, null: false, foreign_key: true
      t.string :status, null: false, default: 'new'
      t.string :billing_first_name, null: false
      t.string :billing_last_name, null: false
      t.string :billing_email, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :postal_code, null: false
      t.string :province_name, null: false
      t.string :province_code, null: false
      t.decimal :subtotal_amount, precision: 10, scale: 2, null: false
      t.decimal :gst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :pst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :hst_rate, precision: 5, scale: 4, null: false, default: 0
      t.decimal :gst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :pst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :hst_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax_total_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :payment_processor
      t.string :payment_reference
      t.datetime :paid_at
      t.datetime :shipped_at
      t.timestamps
    end

    add_index :orders, :status

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_title, null: false
      t.integer :quantity, null: false
      t.decimal :unit_price_amount, precision: 10, scale: 2, null: false
      t.decimal :line_total_amount, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
