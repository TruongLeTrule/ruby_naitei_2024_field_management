class ApplicationController < ActionController::Base
  include SessionsHelper
  include UsersHelper
  include Pagy::Backend

  before_action :set_locale

  private

  def set_locale
    return I18n.locale = params[:locale] if params[:locale].present?

    I18n.locale = I18n.default_locale
    redirect_to url_for(locale: I18n.default_locale)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.errors.require_login"
    redirect_to root_path status: :see_other
  end

  def valid_user?
    return if current_user.id == @order.user_id

    flash[:danger] = t "users.errors.invalid"
    redirect_to root_path
  end

  def find_order_by_id
    @order = OrderField.find_by id: params[:id]
    return if @order

    flash[:danger] = t "orders.errors.invalid"
    redirect_to root_path
  end
end
