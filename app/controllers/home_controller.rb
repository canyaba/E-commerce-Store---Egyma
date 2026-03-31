# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @products = Product.active_catalog.with_attached_image.includes(:categories).page(params[:page]).per(6)
    @featured_categories = Category.alphabetical.limit(4)
  end
end
