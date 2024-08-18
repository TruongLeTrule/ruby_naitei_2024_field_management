class BookingHistoryController < ApplicationController
  authorize_resource class: "OrderField"

  def index
    @user_orders = OrderField.accessible_by(current_ability)
                             .includes(:user, :field)
                             .search_by_field_name(params[:field])
                             .search_by_date(params[:date])
                             .search_by_status(params[:status])
    sort_column = params[:sort_column] || "created_at"
    sort_direction = params[:sort_direction] || "desc"
    @user_orders = @user_orders.order(sort_column => sort_direction)
    @pagy, @user_orders = pagy(@user_orders)
  end
end
