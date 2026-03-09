module Admin
  class SettingsController < BaseController
    layout "dashboard"

    def show
      @mpesa_mode = Setting.mpesa_mode
    end

    def update
      Setting.mpesa_mode = params[:mpesa_mode] if params[:mpesa_mode].present?

      redirect_to admin_settings_path, notice: "Settings updated successfully."
    end
  end
end
