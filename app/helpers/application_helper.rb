module ApplicationHelper
  include Pagy::Frontend

  def full_title title
    base_title = t "app_name"
    title.blank? ? base_title : "#{title} | #{base_title}"
  end

  def exchange_money amount
    number_to_currency(amount * t("number.money.exchange_rate"))
  end

  def sortable column, title = nil
    title ||= column.to_s.titleize
    direction = if column.to_s == params[:sort_column]
                  params[:sort_direction] == "asc" ? "desc" : "asc"
                else
                  "desc"
                end
    link_to title,
            url_for(request.query_parameters.merge(sort_column: column,
                                                   sort_direction: direction))
  end
end
