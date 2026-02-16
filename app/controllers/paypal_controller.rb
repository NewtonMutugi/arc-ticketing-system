class PaypalController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access

  # Base URL for Sandbox or Live
  BASE_URL = Rails.env.production? ? "https://api-m.paypal.com" : "https://api-m.sandbox.paypal.com"

  def create_order
    order = Order.find_by(order_no: params[:order_no])

    usd_amount = (order.total_cost / 130.0).round(2).to_s

    body = {
      intent: "CAPTURE",
      purchase_units: [ {
        reference_id: order.order_no,
        amount: {
          currency_code: "USD",
          value: usd_amount
        }
      } ]
    }

    response = paypal_request(:post, "/v2/checkout/orders", body)
    render json: response
  end

  def capture_order
    paypal_order_id = params[:orderID]
    order_no = params[:order_no]

    response = paypal_request(:post, "/v2/checkout/orders/#{paypal_order_id}/capture", {})

    if response["status"] == "COMPLETED"
      order = Order.find_by(order_no: order_no)

      if order
        order.update(
          status: :paid,
          payment_provider: "Paypal",
          payment_reference: response["id"] # PayPal Transaction ID
        )

        # Send Email immediately
        OrderMailer.confirmation_email(order).deliver_now

        render json: { status: "COMPLETED" }
      else
        render json: { error: "Order not found" }, status: 404
      end
    else
      render json: { error: "Capture failed" }, status: 500
    end
  end

  private

  def get_access_token
    client_id = ENV["PAYPAL_CLIENT_ID"]
    secret = ENV["PAYPAL_CLIENT_SECRET"]
    auth = Base64.strict_encode64("#{client_id}:#{secret}")

    response = Faraday.post("#{BASE_URL}/v1/oauth2/token") do |req|
      req.headers["Authorization"] = "Basic #{auth}"
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = "grant_type=client_credentials"
    end

    JSON.parse(response.body)["access_token"]
  end

  def paypal_request(method, endpoint, payload)
    token = get_access_token

    response = Faraday.public_send(method, "#{BASE_URL}#{endpoint}") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json unless payload.empty?
    end

    JSON.parse(response.body)
  end
end
