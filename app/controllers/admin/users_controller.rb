module Admin
  class UsersController < BaseController
    def create
      # Check if user already exists
      if User.exists?(email_address: params[:email_address])
        redirect_to admin_settings_path, alert: "User with that email already exists."
        return
      end

      # Generate a secure random password for the initial creation
      random_password = SecureRandom.alphanumeric(12)

      @user = User.new(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email_address: params[:email_address],
        password: random_password,
        password_confirmation: random_password
      )

      if @user.save
        # Send a password reset email so the user can set their own password
        PasswordsMailer.reset(@user).deliver_now
        redirect_to admin_settings_path, notice: "User created successfully. An email has been sent to them to set their password."
      else
        error_msg = @user.errors.full_messages.to_sentence
        redirect_to admin_settings_path, alert: "Failed to create user: #{error_msg}"
      end
    end

    def destroy
      @user = User.find(params[:id])

      # Prevent user from deleting themselves
      if @user == Current.user
        redirect_to admin_settings_path, alert: "You cannot delete your own account."
        return
      end

      if @user.destroy
        redirect_to admin_settings_path, notice: "User deleted successfully."
      else
        redirect_to admin_settings_path, alert: "Could not delete user."
      end
    end
  end
end
