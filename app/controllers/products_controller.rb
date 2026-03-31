# frozen_string_literal: true

class ProductsController < ApplicationController
  def show
    @product = Product.active_catalog.with_attached_image.includes(:categories).find(params[:id])
  end
end
