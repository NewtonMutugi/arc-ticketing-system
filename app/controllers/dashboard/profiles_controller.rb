class Dashboard::ProfilesController < ApplicationController
  layout "dashboard"
  before_action :set_user

  def show
  end

  def update
    if Current.user.update(profile_params)
      redirect_to profile_path, status: :see_other, notice: "Your Profile was updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def profile_params
    params.expect(user: [ :first_name, :last_name, :avatar ])
  end
end
