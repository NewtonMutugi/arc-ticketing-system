class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include Pagy::Method
  allow_browser versions: :modern

  before_action :set_current_request_context

  private

  def set_current_request_context
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
  end
end
