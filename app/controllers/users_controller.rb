class UsersController < ApplicationController
  before_action :logged_in_user, excpet: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  def show; end

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

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash.now[:danger] = t ".failed"
      render :edit, status: :unprocessable_entity
    end
  end

  def index; end

  private

  def user_params
    params.require(:user).permit(User::PERMITTED_ATTRIBUTES)
  end
end
