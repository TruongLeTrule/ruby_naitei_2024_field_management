module ApplicationHelper
  include Pagy::Frontend

  def full_title title
    base_title = t "app_name"
    title.blank? ? base_title : "#{title} | #{base_title}"
  end

  def exchange_money amount
    amount * t("number.money.exchange_rate")
  end
end
