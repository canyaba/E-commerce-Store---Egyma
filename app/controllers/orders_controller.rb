# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: :show

  def index
    @orders = current_user.orders.includes(:province, :order_items).recent_first
  end

  def show; end

  private

  def set_order
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end
end
