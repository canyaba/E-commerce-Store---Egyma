# frozen_string_literal: true

class CategoriesController < ApplicationController
  def show
    @category = Category.includes(products: [{ image_attachment: :blob }]).find_by!(slug: params[:slug])
    @selected_filter = params[:filter].to_s
    @products = @category.products
                         .active_catalog
                         .for_catalog_filter(@selected_filter)
                         .with_attached_image
                         .includes(:categories)
                         .page(params[:page])
                         .per(6)
  end
end
