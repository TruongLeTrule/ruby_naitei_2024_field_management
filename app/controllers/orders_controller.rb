class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order_by_id, only: %i(show edit update destroy)
  before_action :find_schedule_by_order_id, only: :update
  before_action :admin_user, only: %i(index show)
  before_action :valid_user?, only: %i(edit update destroy)
  before_action :find_all_orders, only: :index

  def show; end

  def index
    @q = OrderField.ransack(params[:q])
    @pagy, @orders = pagy(@q.result(distance: true).includes(:user, :field))
  end

  def new; end

  def create; end

  def edit; end

  def update
    ActiveRecord::Base.transaction do
      case order_params[:status]
      when "approved"
        return failed_update(t(".payment_fail")) unless handle_payment

        @schedule.update! status: :rent
      when "cancelling"
        @order.send_delete_order_email
        @schedule.update!(status: :pending)
      when "cancel"
        handle_cancel
        @schedule.destroy!
      end
      @order.update_attribute(:status, order_params[:status])
      successful_update
    end
  rescue ActiveRecord::RecordInvalid => e
    failed_update e.message.split(", ")[0]
  end

  def destroy; end

  def export
    @q = OrderField.ransack(params[:q])
    @orders_for_excel = @q.result(distance: true).includes(:user, :field)
    respond_to do |format|
      format.json do
        @job_id = OrderExportJob.perform_async(@orders_for_excel.as_json(
                                                 include: [:user, :field]
                                               ))
        render json: {
          jid: @job_id
        }
      end
    end
  end

  def export_status
    respond_to do |format|
      format.json do
        job_id = params[:job_id]
        job_status = Sidekiq::Status.get_all(job_id).symbolize_keys
        render json: {
          status: job_status[:status],
          percentage: job_status[:pct_complete]
        }
      end
    end
  end

  def export_download
    job_id = params[:job_id]

    respond_to do |format|
      format.xlsx do
        send_file Rails.root.join("public", "data", "orders_#{job_id}.xlsx")
      end
    end
  end

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

  def failed_update msg
    flash.now[:danger] = msg
    render :edit, status: :unprocessable_entity
  end

  def invalid_order
    flash[:danger] = t "orders.errors.invalid"
    redirect_to root_path
  end

  def find_all_orders
    @orders = OrderField.includes(:user, :field).all
  end

  def handle_payment
    voucher = Voucher.find_by id: session[:voucher_id]
    final_price = @order.final_price

    if voucher
      return false unless voucher.valid_voucher?(current_user)

      final_price = voucher.calculate_discount_price final_price
      voucher.destroy!
      session.delete :voucher_id
    end

    return false unless current_user.can_pay? final_price

    @order.update_attribute :final_price, final_price
    current_user.pay final_price
  end

  def handle_cancel
    @order.send_confirm_delete_email params[:reason]
    @order.user.charge @order.final_price
  end
end
