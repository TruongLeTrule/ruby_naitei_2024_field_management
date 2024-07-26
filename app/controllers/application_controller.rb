class ApplicationController < ActionController::Base
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
end
