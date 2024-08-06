class ApplicationController < ActionController::Base
  include SessionsHelper
  include UsersHelper
  include Pagy::Backend

  before_action :set_locale

  private

  def set_locale
    return I18n.locale = params[:locale] if params[:locale].present?

    I18n.locale = I18n.default_locale
    redirect_to url_for(request.params.merge(locale: I18n.default_locale))
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.errors.require_login"
    redirect_to login_path status: :see_other
  end

  def valid_user?
    return if current_user.id == @order.user_id || current_user.admin?

    flash[:danger] = t "users.errors.invalid"
    redirect_to root_path
  end

  def find_order_by_id
    @order = OrderField.find_by id: params[:id] || params[:order_id]
    return if @order

    flash[:danger] = t "orders.errors.invalid"
  end

  def find_field_by_id
    return if @field = Field.find_by(id: params[:id] || params[:field])

    flash[:danger] = t "fields.errors.invalid"
    redirect_to root_path
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t "users.errors.invalid"
    redirect_to root_path
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.show.user_not_found"
    redirect_to root_path
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "users.errors.not_correct_user"
    redirect_to root_path, status: :see_other
  end

  def load_rating
    @rating = Rating.find_by id: params[:id]
    return if @rating

    flash["danger"] = t "ratings.errors.not_found"
    redirect_to root_path
  end
end
