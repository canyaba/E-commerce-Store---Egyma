# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @query = params[:query].to_s.strip
    @selected_category_id = params[:category_id].to_s
    @selected_filter = params[:filter].to_s
    @products = filtered_products.page(params[:page]).per(6)
  end

  private

  def filtered_products
    Product.active_catalog
           .keyword_search(@query)
           .for_category(@selected_category_id)
           .for_catalog_filter(@selected_filter)
           .with_attached_image
           .includes(:categories)
  end
end
