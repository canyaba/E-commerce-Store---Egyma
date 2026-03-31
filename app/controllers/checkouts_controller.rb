# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_non_empty_cart!
  before_action :load_checkout_state

  def show
    preview_checkout
  end

  def create
    @user.assign_attributes(checkout_params)
    preview_checkout
    return render_invalid_checkout if @user.invalid?(:checkout)

    create_order
  rescue Orders::CreateFromCart::Error => e
    render_checkout_error(e.message)
  end

  private

  def load_checkout_state
    @cart = current_cart
    @user = current_user
    @provinces = Province.alphabetical
  end

  def preview_checkout
    selected_province = if checkout_params[:province_id].present?
                          Province.find_by(id: checkout_params[:province_id])
                        else
                          @user.province
                        end

    @pricing = Orders::PricingPreview.new(cart: @cart, province: selected_province).call
  end

  def checkout_params
    params.fetch(:user, {}).permit(
      :first_name,
      :last_name,
      :address_line_1,
      :address_line_2,
      :city,
      :postal_code,
      :province_id
    )
  end

  def create_order
    @order = Orders::CreateFromCart.new(user: @user, cart: current_cart).call
    current_cart.clear!
    redirect_to order_path(@order), notice: 'Order created. Complete sandbox payment to finish checkout.'
  end

  def render_invalid_checkout
    render_checkout_error('Please fix the checkout details below.')
  end

  def render_checkout_error(message)
    flash.now[:alert] = message
    render :show, status: :unprocessable_content
  end
end
