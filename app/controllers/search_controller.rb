# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @query = params[:query].to_s.strip
    @selected_category_id = params[:category_id].to_s
    @products = Product.active_catalog
                       .keyword_search(@query)
                       .for_category(@selected_category_id)
                       .with_attached_image
                       .includes(:categories)
                       .page(params[:page])
                       .per(6)
  end
end
