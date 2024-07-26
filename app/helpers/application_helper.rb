module ApplicationHelper
  include Pagy::Frontend

  def full_title title
    base_title = t "app_name"
    title.blank? ? base_title : "#{title} | #{base_title}"
  end
end
