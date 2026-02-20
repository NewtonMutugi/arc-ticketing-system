require "faraday"
require "base64"
require "json"

class MpesaService
  BASE_URL = Rails.env.production? ? "https://api.safaricom.co.ke" : "https://sandbox.safaricom.co.ke"
  CALLBACK_URL = Rails.env.production? ? ENV["PROD_MPESA_CALLBACK_URL"] : ENV["MPESA_CALLBACK_URL"]

  def initialize(order)
    @order = order
  end

  def stk_push(phone_number_override = nil)
    phone = phone_number_override || @order.buyer_phone_no
    formatted_phone = format_phone(phone)

    token = get_access_token

    unless token
      return {
        "ResponseCode" => "Error",
        "CustomerMessage" => "Failed to retrieve MPESA access token. Please check configuration."
      }
    end
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
        CallBackURL: CALLBACK_URL,
        AccountReference: @order.order_no,
        TransactionDesc: "Ticket Payment"
      }.to_json
    end

    begin
      result = JSON.parse(response.body)

      unless response.success?
        error_msg = result["errorMessage"] || result["CustomerMessage"] || "M-Pesa API Error (#{response.status})"
        Rails.logger.error("MPESA STK PUSH ERROR #{response.status}: #{error_msg}")
        # Add the 'return' keyword here to stop execution
        { "ResponseCode" => "Error", "CustomerMessage" => error_msg }
      end
    rescue JSON::ParserError => e
      Rails.logger.error("MPESA STK PUSH PARSE ERROR. Status: #{response.status}, Body: #{response.body}")
      { "ResponseCode" => "Error", "CustomerMessage" => "Invalid response from M-Pesa. Status: #{response.status}" }
    end
  end

  private

  def get_access_token
    key = ENV["MPESA_CONSUMER_KEY"]
    secret = ENV["MPESA_CONSUMER_SECRET"]
    auth = Base64.strict_encode64("#{key}:#{secret}")

    response = connection.get("/oauth/v1/generate?grant_type=client_credentials") do |req|
      req.headers["Authorization"] = "Basic #{auth}"
    end

    # Catch empty bodies (Firewall drops / IP not whitelisted)
    if response.body.blank?
      Rails.logger.error("MPESA FATAL: Empty response! HTTP Status: #{response.status}")
      Rails.logger.error("MPESA CHECK: Are your ENV keys loaded? Key present: #{key.present?}")
      return nil
    end

    # Catch actual API errors (Bad credentials)
    unless response.success?
      Rails.logger.error("MPESA API ERROR #{response.status}: #{response.body}")
      return nil
    end

    # Safely parse
    begin
      JSON.parse(response.body)["access_token"]
    rescue JSON::ParserError => e
      Rails.logger.error("MPESA PARSE ERROR: #{e.message} - Body was: #{response.body}")
      nil
    end
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
