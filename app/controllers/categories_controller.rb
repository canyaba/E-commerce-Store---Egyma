# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.includes(products: [{ image_attachment: :blob }]).find_by!(slug: params[:slug])
    @products = @category.products.active_catalog.with_attached_image.includes(:categories).page(params[:page]).per(6)
  end
end
