module Admin
  class UsersController < BaseController
    layout "dashboard"

    def create
      authorize User
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
        role: params[:role] || "viewer",
        password: random_password,
        password_confirmation: random_password
      )

      if @user.save
        # Send a password reset email so the user can set their own password
        PasswordsMailer.reset(@user).deliver_later
        redirect_to admin_settings_path, notice: "User created successfully. An email has been sent to them to set their password."
      else
        error_msg = @user.errors.full_messages.to_sentence
        redirect_to admin_settings_path, alert: "Failed to create user: #{error_msg}"
      end
    end

    def destroy
      @user = User.find(params[:id])
      authorize @user

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

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user

      role = params.dig(:user, :role) || params[:role]

      if User.roles.key?(role)
        @user.update!(role: role)
        respond_to do |format|
          format.html { redirect_to admin_settings_path, notice: "User role updated successfully." }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("user_#{@user.id}", partial: "admin/users/user_row", locals: { user: @user }),
              turbo_stream.update("modal", ""),
              turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Success", body: "User role updated successfully." })
            ]
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to admin_settings_path, alert: "Invalid role selected." }
          format.turbo_stream do
            render turbo_stream: turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :error, title: "Error", body: "Invalid role selected." })
          end
        end
      end
    end
  end
end
