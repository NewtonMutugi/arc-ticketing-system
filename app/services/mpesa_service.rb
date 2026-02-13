require "faraday"
require "base64"
require "json"

class MpesaService
  BASE_URL = Rails.env.production? ? "https://api.safaricom.co.ke" : "https://sandbox.safaricom.co.ke"

  def initialize(order)
    @order = order
  end

  def stk_push(phone_number_override = nil)
    phone = phone_number_override || @order.buyer_phone_no
    formatted_phone = format_phone(phone)

    token = get_access_token
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{shortcode}#{passkey}#{timestamp}")

    response = connection.post("/mpesa/stkpush/v1/processrequest") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        BusinessShortCode: shortcode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: @order.total_cost.to_i,
        PartyA: formatted_phone, # Must be 2547...
        PartyB: shortcode,
        PhoneNumber: formatted_phone,
        CallBackURL: ENV["MPESA_CALLBACK_URL"],
        AccountReference: @order.order_no,
        TransactionDesc: "Ticket Payment"
      }.to_json
    end

    JSON.parse(response.body)
  end

  private

  def get_access_token
    key = ENV["MPESA_CONSUMER_KEY"]
    secret = ENV["MPESA_CONSUMER_SECRET"]
    auth = Base64.strict_encode64("#{key}:#{secret}")

    response = connection.get("/oauth/v1/generate?grant_type=client_credentials") do |req|
      req.headers["Authorization"] = "Basic #{auth}"
    end

    JSON.parse(response.body)["access_token"]
  end

  def connection
    Faraday.new(url: BASE_URL)
  end

  def shortcode
    ENV["MPESA_SHORTCODE"]
  end

  def passkey
    ENV["MPESA_PASSKEY"]
  end

  def format_phone(number)
    # Ensure format is 2547...
    number.gsub(/\A0/, "254").gsub(/\A\+254/, "254")
  end
end
