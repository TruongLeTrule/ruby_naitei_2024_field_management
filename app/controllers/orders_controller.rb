class OrdersController < ApplicationController
  before_action :logged_in_user, only: %i(new create edit update destroy)
  before_action :find_order_by_id, only: %i(show edit update destroy)
  before_action :find_schedule_by_order_id, only: :update
  before_action :valid_user?, only: %i(edit update destroy)

  def show; end

  def index; end

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
        @schedule.update!(status: :rent)
      when "cancel"
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
end
