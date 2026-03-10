module Admin
  class SettingsController < BaseController
    layout "dashboard"

    def show
      @mpesa_mode = Setting.mpesa_mode
      @mpesa_business_number = Setting.mpesa_business_number
    end

    def update
      Setting.mpesa_mode = params[:mpesa_mode] if params[:mpesa_mode].present?
      Setting.mpesa_business_number = params[:mpesa_business_number] if params[:mpesa_business_number].present?

      redirect_to admin_settings_path, notice: "Settings updated successfully."
    end
  end
end
