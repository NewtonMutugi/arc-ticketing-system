require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
    @user.update(role: :admin)
    sign_in_as(@user)
  end

  test "should get show" do
    get admin_settings_path
    assert_response :success
    assert_select "input[name=session_timeout]"
  end

  test "should update settings" do
    patch admin_settings_path, params: {
      mpesa_mode: "manual",
      mpesa_business_number: "654321",
      session_timeout: "60"
    }

    assert_redirected_to admin_settings_path
    assert_equal "manual", Setting.mpesa_mode
    assert_equal "654321", Setting.mpesa_business_number
    assert_equal "60", Setting.session_timeout
  end
end
