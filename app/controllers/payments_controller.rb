# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: :create

  def create
    return redirect_to(order_path(@order), alert: 'Only unpaid orders can be sent to Stripe.') unless @order.payable?

    checkout_session = payment_session_creator.call(
      success_url: payment_success_url(order_id: @order.id, session_id: '{CHECKOUT_SESSION_ID}'),
      cancel_url: order_url(@order)
    )

    redirect_to checkout_session.url, allow_other_host: true
  rescue Payments::StripeCheckoutSessionCreator::Error => e
    redirect_to order_path(@order), alert: e.message
  end

  def success
    @order = current_user.orders.find(params.require(:order_id))
    return redirect_to(order_path(@order), notice: 'This order is already marked as paid.') if @order.paid?

    process_payment_success
  rescue ActionController::ParameterMissing, Payments::StripeCheckoutSessionVerifier::Error => e
    redirect_to orders_path, alert: e.message
  rescue Order::InvalidTransitionError => e
    redirect_to order_path(@order), alert: e.message
  end

  private

  def payment_session_creator
    Payments::StripeCheckoutSessionCreator.new(order: @order)
  end

  def payment_session_verifier
    Payments::StripeCheckoutSessionVerifier.new
  end

  def process_payment_success
    checkout_session = payment_session_verifier.call(session_id: params.require(:session_id))
    return mark_order_paid(checkout_session) if valid_paid_session?(checkout_session)

    redirect_to order_path(@order), alert: 'Stripe did not confirm this payment.'
  end

  def valid_paid_session?(checkout_session)
    checkout_session.payment_status == 'paid' && checkout_session.client_reference_id == @order.id.to_s
  end

  def mark_order_paid(checkout_session)
    @order.mark_paid!(
      reference: checkout_session.payment_intent.presence || checkout_session.id,
      processor: 'stripe'
    )
    redirect_to order_path(@order), notice: 'Sandbox payment completed successfully.'
  end

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end
end
