# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    product = Product.active_catalog.find(cart_item_params[:product_id])

    if current_cart.add_item(product.id, cart_item_params[:quantity])
      redirect_to cart_path, notice: "#{product.title} added to cart."
    else
      redirect_to product_path(product), alert: 'Please choose a valid quantity.'
    end
  end

  def update
    product = Product.active_catalog.find(params[:product_id])

    if current_cart.update_item(product.id, params.require(:quantity))
      redirect_to cart_path, notice: "#{product.title} quantity updated."
    else
      redirect_to cart_path, alert: 'Quantity must be at least 1.'
    end
  end

  def destroy
    product = Product.find_by(id: params[:product_id])

    if current_cart.remove_item(params[:product_id])
      redirect_to cart_path, notice: "#{product&.title || 'Item'} removed from cart."
    else
      redirect_to cart_path, alert: 'That item is no longer in your cart.'
    end
  end

  private

  def cart_item_params
    params.permit(:product_id, :quantity)
  end
end
