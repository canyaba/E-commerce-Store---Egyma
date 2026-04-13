# frozen_string_literal: true

class AddUniqueIndexToProductsTitle < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :title, unique: true, if_not_exists: true
  end
end
