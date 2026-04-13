# frozen_string_literal: true

class ReplaceProductTitleIndexWithUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :products, :title if index_exists?(:products, :title)
    add_index :products, :title, unique: true
  end
end
