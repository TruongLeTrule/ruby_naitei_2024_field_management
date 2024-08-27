class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(index update_active)
  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    @user.image.attach params.dig(:user, :image)
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
    if params.dig(:user, :image).present?
      @user.image.attach(params.dig(:user, :image))
    end

    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
      create_action(@user, :updated, @user)
    else
      flash.now[:danger] = t ".failed"
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @users = User.search_by_name(params[:name])
                 .search_by_email(params[:email])
                 .search_by_status(params[:confirmed])
                 .order_by(params[:sort_column], params[:sort_direction])

    @pagy, @users = pagy(@users)
  end

  def update_active
    success = case params[:confirmed]
              when "true" then @user.confirm_user
              when "false" then @user.unconfirm_user
              else false
              end
    success ? update_active_successful : update_active_fail
  end

  private

  def user_params
    params.require(:user).permit(User::PERMITTED_ATTRIBUTES)
  end

  def update_active_successful
    flash[:success] = t "users.update.success"
    redirect_to users_path
  end

  def update_active_fail
    flash[:danger] = t "users.update.failed"
    redirect_to users_path
  end
end
