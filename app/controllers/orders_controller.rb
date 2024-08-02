class OrdersController < ApplicationController
  before_action :logged_in_user
  before_action :find_order_by_id, only: %i(show edit update destroy)
  before_action :find_schedule_by_order_id, only: :update
  before_action :admin_user, only: %i(index show)
  before_action :valid_user?, only: %i(edit update destroy)
  before_action :find_all_orders, only: :index

  def show; end

  def index
    filter_order
    sort_order
    @pagy, @orders = pagy(@orders)
  end

  def new
    @order = OrderField.new
  end

  def create; end

  def edit; end

  def update
    ActiveRecord::Base.transaction do
      @order.update_attribute(:status, order_params[:status])

      case order_params[:status]
      when "approved"
        update_final_price
        @schedule.update! status: :rent
      when "cancelling"
        @order.send_delete_order_email
        @schedule.update!(status: :pending)
      when "cancel"
        @order.send_confirm_delete_email
        @schedule.destroy!
      end
      successful_update
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
    failed_update
  end

  def destroy; end

  private

  def order_params
    params.require(:order_field).permit OrderField::UPDATE_ATTRIBUTES
  end

  def find_schedule_by_order_id
    @schedule = UnavailableFieldSchedule.find_by order_field_id: @order.id
    return if @schedule

    invalid_order
  end

  def successful_update
    flash[:success] = t "orders.update.success"
    redirect_to edit_order_path(@order)
  end

  def failed_update
    flash.now[:danger] = t "orders.update.failed"
    render :edit, status: :unprocessable_entity
  end

  def invalid_order
    flash[:danger] = t "orders.errors.invalid"
    redirect_to root_path
  end

  def find_all_orders
    @orders = OrderField.includes(:user, :field).all
  end

  def filter_order
    @orders = @orders.search_by_user_name(params[:user])
                     .search_by_field_name(params[:field])
                     .search_by_date(params[:date])
                     .search_by_status(params[:status])
  end

  def sort_order
    sort_column = params[:sort_column] || "id"
    sort_direction = params[:sort_direction] || "asc"
    @orders = @orders.order(sort_column => sort_direction)
  end

  def update_final_price
    voucher = Voucher.find_by id: session[:voucher_id]
    return unless voucher&.valid? current_user

    @order.update_attribute :final_price,
                            voucher.get_discount_price(@order.final_price)
    voucher.destroy!
    session.delete :voucher_id
  end
end
