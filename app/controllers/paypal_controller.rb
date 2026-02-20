class PaypalController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access

  BASE_URL = Rails.env.production? ? "https://api-m.paypal.com" : "https://api-m.sandbox.paypal.com"
  CLIENT_ID = Rails.env.production? ? ENV["PROD_PAYPAL_CLIENT_ID"] : ENV["PAYPAL_CLIENT_ID"]
  CLIENT_SECRET = Rails.env.production? ? ENV["PROD_PAYPAL_CLIENT_SECRET"] : ENV["PAYPAL_CLIENT_SECRET"]

  def create_order
    order = Order.find_by(order_no: params[:order_no])

    # Validation: Ensure order exists
    unless order
      # render json: { error: "Order not found" }, status: :not_found
      return render_error_toast("Order not found in the system. Please try again.")
    end

    # Calculate amount in USD
    usd_amount = (order.total_cost / 130.0).round(2).to_s

    body = {
      intent: "CAPTURE",
      purchase_units: [ {
        reference_id: order.order_no,
        amount: { currency_code: "USD", value: usd_amount }
      } ]
    }

    # API Call
    response = paypal_request(:post, "/v2/checkout/orders", body)

    # CHECK: Did PayPal return an ID?
    if response["id"]
      render json: response
    else
      # LOG THE ERROR: This will show up in your terminal
      Rails.logger.error("PAYPAL CREATE ERROR: #{response.inspect}")
      error_message = response["error"] || "Could not initiate PayPal payment. Please check configuration."
      # render json: { error: "PayPal API Error", details: response }, status: :unprocessable_entity
      render_error_toast(error_message)
    end
  end

  def capture_order
    paypal_order_id = params[:orderID]
    order_no = params[:order_no]

    response = paypal_request(:post, "/v2/checkout/orders/#{paypal_order_id}/capture", {})

    # CHECK: Did the capture complete?
    if response["status"] == "COMPLETED"
      order = Order.find_by(order_no: order_no)

      if order
        order.update(
          status: :paid,
          payment_provider: "Paypal",
          payment_reference: response["id"]
        )
        # Send Email
        OrderMailer.confirmation_email(order).deliver_now
        render json: { status: "COMPLETED" }
      else
        # render json: { error: "Order not found in system" }, status: 404
        render_error_toast("Payment successful, but order was not found.")
      end
    else
      # LOG THE ERROR
      Rails.logger.error("PAYPAL CAPTURE ERROR: #{response.inspect}")
      # render json: { error: "Capture failed", details: response }, status: :unprocessable_entity
      render_error_toast("Payment capture failed. Please try again.")
    end
  end

  private

  def render_error_toast(message)
    render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "PayPal Error", body: message)), status: :unprocessable_entity
  end

  def get_access_token
    # Using ENV as requested
    client_id = CLIENT_ID
    secret = CLIENT_SECRET

    # Safety Check
    if client_id.blank? || secret.blank?
      Rails.logger.error("PAYPAL CONFIG ERROR: Missing ENV variables")
      return nil
    end

    auth = Base64.strict_encode64("#{client_id}:#{secret}")

    response = Faraday.post("#{BASE_URL}/v1/oauth2/token") do |req|
      req.headers["Authorization"] = "Basic #{auth}"
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = "grant_type=client_credentials"
    end

    json = JSON.parse(response.body)

    # Check if token generation failed
    if json["error"]
      Rails.logger.error("PAYPAL TOKEN ERROR: #{json}")
      return nil
    end

    json["access_token"]
  end

  def paypal_request(method, endpoint, payload)
    token = get_access_token

    # Fail fast if we couldn't get a token
    return { "error" => "Could not authenticate with PayPal" } unless token

    response = Faraday.public_send(method, "#{BASE_URL}#{endpoint}") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.headers["Content-Type"] = "application/json"
      req.body = payload.to_json unless payload.empty?
    end

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.error("PAYPAL JSON ERROR: #{e.message}")
    { "error" => "Invalid response from PayPal" }
  rescue Faraday::Error => e
    Rails.logger.error("PAYPAL NETWORK ERROR: #{e.message}")
    { "error" => "Network error connecting to PayPal" }
  end
end
