require "faraday"
require "base64"
require "json"

class MpesaService
  BASE_URL = Rails.env.production? ? "https://api.safaricom.co.ke" : "https://sandbox.safaricom.co.ke"
  CALLBACK_URL = Rails.env.production? ? ENV["PROD_MPESA_CALLBACK_URL"] : ENV["MPESA_CALLBACK_URL"]

  def initialize(payable)
    @payable = payable
  end

  def stk_push(phone_number_override = nil)
    phone = phone_number_override || @payable.try(:buyer_phone_no)
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
        TransactionType: "CustomerBuyGoodsOnline",
        Amount: (@payable.try(:total_cost) || @payable.try(:amount_paid)).to_i,
        PartyA: formatted_phone, # Must be 2547...
        PartyB: till_number,
        PhoneNumber: formatted_phone,
        CallBackURL: CALLBACK_URL,
        AccountReference: @payable.try(:order_no) || "UPG-#{@payable.id}",
        TransactionDesc: "Ticket Payment"
      }.to_json
    end

    begin
      result = JSON.parse(response.body)

      if response.success?
        result
      else
        error_msg = result["errorMessage"] || result["CustomerMessage"] || "M-Pesa API Error (#{response.status})"
        Rails.logger.error("MPESA STK PUSH ERROR #{response.status}: #{error_msg}")
        { "ResponseCode" => "Error", "CustomerMessage" => error_msg }
      end
    rescue JSON::ParserError => e
      Rails.logger.error("MPESA STK PUSH PARSE ERROR. Status: #{response.status}, Body: #{response.body}")
      { "ResponseCode" => "Error", "CustomerMessage" => "Invalid response from M-Pesa. Status: #{response.status}" }
    end
  end

  private

  def get_access_token
    # Daraja tokens are valid ~1hr. Caching avoids hitting /oauth/v1/generate
    # on every STK push, which otherwise trips Safaricom's WAF bot-protection
    # under repeated requests.
    Rails.cache.fetch("mpesa_access_token_#{Rails.env}", expires_in: 55.minutes, skip_nil: true) do
      fetch_new_access_token
    end
  end

  def fetch_new_access_token
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

  def till_number
    ENV["MPESA_TILL_NUMBER"] || shortcode
  end

  def passkey
    ENV["MPESA_PASSKEY"]
  end

  def format_phone(number)
    # Ensure format is 2547...
    number.gsub(/\A0/, "254").gsub(/\A\+254/, "254")
  end
end
