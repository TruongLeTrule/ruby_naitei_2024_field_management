class BookingHistoryController < ApplicationController
  before_action :logged_in_user

  def index
    find_orders_by_user
    @user_orders = @user_orders.search_by_field_name(params[:field])
                               .search_by_date(params[:date])
                               .search_by_status(params[:status])
    sort_column = params[:sort_column] || "created_at"
    sort_direction = params[:sort_direction] || "desc"
    @user_orders = @user_orders.order(sort_column => sort_direction)
    @pagy, @user_orders = pagy(@user_orders)
  end

  private

  def find_orders_by_user
    @user_orders = OrderField.where(user_id: current_user&.id)
                             .includes(:user, :field)

    return if @user_orders

    flash[:danger] = t "orders.errors.invalid"
    redirect_to root_path
  end
end
