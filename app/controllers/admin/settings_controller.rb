module Admin
  class SettingsController < BaseController
    layout "dashboard"

    def show
      authorize Setting
      @mpesa_mode = Setting.mpesa_mode
      @mpesa_business_number = Setting.mpesa_business_number
      @session_timeout = Setting.session_timeout
      @users = User.all.order(created_at: :desc)
    end

    def update
      authorize Setting


      Setting.mpesa_mode = params[:mpesa_mode] if params[:mpesa_mode].present?
      Setting.mpesa_business_number = params[:mpesa_business_number] if params[:mpesa_business_number].present?
      Setting.session_timeout = params[:session_timeout] if params[:session_timeout].present?

      redirect_to admin_settings_path, notice: "Settings updated successfully."
    end
  end
end
