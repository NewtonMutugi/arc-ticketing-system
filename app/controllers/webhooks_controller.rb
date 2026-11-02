class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access

  def mpesa
    body = params[:Body][:stkCallback]

    # 1. Find Order or Upgrade
    checkout_id = body[:CheckoutRequestID]
    payable = Order.find_by(checkout_request_id: checkout_id) || TicketUpgrade.find_by(checkout_request_id: checkout_id)

    return head :not_found unless payable

    # 2. Check Result Code (0 means success)
    if body[:ResultCode] == 0
      # Extract Receipt Number (M-Pesa Code)
      receipt = body[:CallbackMetadata][:Item].find { |i| i[:Name] == "MpesaReceiptNumber" }[:Value]

      payable.update(
        status: :paid,
        payment_reference: receipt,
        payment_provider: "Mpesa"
      )

      if payable.is_a?(Order)
        payable.send_confirmation_emails!
      elsif payable.is_a?(TicketUpgrade)
        payable.apply_upgrade!
      end
    else
      payable.update(status: :failed)
    end

    render json: { result: "ok" }
  end
end
