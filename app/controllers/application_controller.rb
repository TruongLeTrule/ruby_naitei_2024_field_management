class ApplicationController < ActionController::Base
  include SessionsHelper
  include UsersHelper
  include ActivitiesHelper
  include Pagy::Backend

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  def configure_permitted_parameters
    added_attrs = [:name, :email, :password, :password_confirmation,
                  :remember_me, :image]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private

  def set_locale
    return I18n.locale = params[:locale] if params[:locale].present?

    I18n.locale = I18n.default_locale
    return if request.params.keys.include?("authuser")

    redirect_to url_for(request.params.merge(locale: I18n.default_locale))
  end

  def default_url_options
    {locale: I18n.locale}
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
