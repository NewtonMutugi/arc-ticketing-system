class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access

  def mpesa
    body = params[:Body][:stkCallback]

    # 1. Find Order
    checkout_id = body[:CheckoutRequestID]
    order = Order.find_by(checkout_request_id: checkout_id)

    return head :not_found unless order

    # 2. Check Result Code (0 means success)
    if body[:ResultCode] == 0
      # Extract Receipt Number (M-Pesa Code)
      receipt = body[:CallbackMetadata][:Item].find { |i| i[:Name] == "MpesaReceiptNumber" }[:Value]

      order.update(
        status: :paid,
        payment_reference: receipt,
        payment_provider: "Mpesa"
      )

      # Send Email
      OrderMailer.confirmation_email(order).deliver_later
    else
      order.update(status: :failed)
    end

    render json: { result: "ok" }
  end
end
