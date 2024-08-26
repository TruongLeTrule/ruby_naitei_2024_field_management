class Admin::OrderFieldsController < Admin::AdminController
  def stats
    @q = OrderField.ransack params[:q]
    @orders = @q.result.includes field: :field_type
    @line_chart_data = exchange_revenue @orders.group_by_time(
      params[:group_by]&.to_sym || :day
    )
    @field_pie_chart_data = exchange_revenue @orders.group_revenue_by_field
    @field_type_pie_chart_data = exchange_revenue(
      @orders.group_revenue_by_field_type
    )
  end

  private

  def exchange_revenue data
    data.transform_values{|value| value * t("number.money.exchange_rate")}
  end
end
