class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".user_not_found"
    redirect_to root_url
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_email"
      redirect_to root_url, status: :see_other
    else
      flash.now[:danger] = t ".failed"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(User::PERMITTED_ATTRIBUTES)
  end
end
