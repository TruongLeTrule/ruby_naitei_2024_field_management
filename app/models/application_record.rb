class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ActivitiesHelper

  def translate_enum enum_name, enum_value
    enum_i18n_key = enum_name.to_s.pluralize
    I18n.t("activerecord.attributes.#{model_name.i18n_key}" \
           ".#{enum_i18n_key}.#{enum_value}")
  end
end
