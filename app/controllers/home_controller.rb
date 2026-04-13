# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @selected_filter = params[:filter].to_s
    @products = Product.active_catalog
                       .for_catalog_filter(@selected_filter)
                       .with_attached_image
                       .includes(:categories)
                       .page(params[:page])
                       .per(6)
    @featured_categories = Category.alphabetical.limit(4)
  end
end
