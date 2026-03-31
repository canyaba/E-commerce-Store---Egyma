# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :store_admin_location, if: :track_admin_location?

  helper_method :current_cart, :search_categories, :storefront_categories

  private

  def current_cart
    @current_cart ||= Cart.new(session)
  end

  def search_categories
    @search_categories ||= Category.alphabetical
  end

  def storefront_categories
    @storefront_categories ||= Category.alphabetical.limit(6)
  end

  def require_non_empty_cart!
    return unless current_cart.empty?

    redirect_to cart_path, alert: 'Your cart is empty. Add a product before continuing.'
  end

  def track_admin_location?
    current_admin_user.present? && request.get? && request.path.start_with?('/admin')
  end

  def store_admin_location
    session[:admin_last_path] = request.fullpath
  end
end
