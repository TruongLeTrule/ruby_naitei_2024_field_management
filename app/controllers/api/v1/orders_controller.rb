class Api::V1::OrdersController < ApplicationController
  before_action :find_order_by_id, only: %i(show update destroy)
  before_action :find_schedule_by_order_id, only: :update
  before_action :find_field_by_id, only: :create
  before_action :find_user_by_id, only: %i(create update)
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @q = OrderField.ransack(params[:q])
    @pagy, @orders = pagy(@q.result(distance: true).includes(:user, :field))
    render json: {
             orders: @orders.as_json(include: [:user, :field]),
             pagination: covert_pagy_to_json(@pagy)
           },
           status: :ok
  end

  def show
    render json: @order.as_json(include: [:user, :field]), status: :ok
  end

  def create
    ActiveRecord::Base.transaction do
      @order = build_order
      @order.save!
      @schedule = create_schedule
      render json: @order.as_json(include: [:unavailable_field_schedule,
                                            :user,
                                            :field]),
             status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
    render json: {errors: @order.errors.full_messages},
           status: :unprocessable_entity
  end

  def update
    ActiveRecord::Base.transaction do
      case order_params[:status].to_sym
      when :approved
        handle_approved
      when :cancelling
        @order.send_delete_order_email
        @schedule.update!(status: :pending)
      when :cancel
        handle_cancel
        @schedule.destroy!
      end

      if @order.update_attribute(:status, order_params[:status])
        render json: @order.as_json(include: [:user, :field]), status: :ok
      else
        render_failed_update
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
    render_failed_update
  end

  def destroy
    if @order.destroy
      head :no_content
    else
      render json: {errors: @order.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def export
    @q = OrderField.ransack(params[:q])
    @orders_for_excel = @q.result(distance: true).includes(:user, :field)
    @job_id = OrderExportJob.perform_async(@orders_for_excel
                            .as_json(include: [:user, :field]))
    render json: {jid: @job_id}, status: :ok
  end

  def export_status
    job_id = params[:job_id]
    job_status = Sidekiq::Status.get_all(job_id).symbolize_keys
    render json: {
      status: job_status[:status],
      percentage: job_status[:pct_complete]
    }, status: :ok
  end

  def export_download
    job_id = params[:job_id]
    file_path = Rails.root.join("public", "data", "orders_#{job_id}.xlsx")

    if File.exist?(file_path)
      send_file file_path, type: :xlsx, disposition: :attachment
    else
      render json: {error: I18n.t("orders.errors.file_not_found")},
             status: :not_found
    end
  end

  private

  def order_params
    params.require(:order_field).permit OrderField::UPDATE_ATTRIBUTES
  end

  def create_order_params
    params.require(:order_field).permit OrderField::CREATE_ATTRIBUTES
  end

  def find_order_by_id
    @order = OrderField.find_by id: params[:id]
    return if @order

    render json: {error: I18n.t("orders.errors.invalid")}, status: :not_found
  end

  def find_schedule_by_order_id
    @schedule = UnavailableFieldSchedule.find_by order_field_id: @order.id
    return if @schedule

    render json: {error: I18n.t("orders.errors.invalid")}, status: :not_found
  end

  def find_field_by_id
    @field = Field.find_by id: params[:field_id]
    return if @field

    render json: {error: I18n.t("fields.errors.invalid")}, status: :not_found
  end

  def find_user_by_id
    @user = User.find_by id: params[:user_id] || @order.user_id
    return if @user

    render json: {error: I18n.t("users.errors.invalid")}, status: :not_found
  end

  def render_failed_update
    render json: {errors: @order.errors.full_messages},
           status: :unprocessable_entity
  end

  def handle_payment
    voucher = Voucher.find_by id: session[:voucher_id]
    final_price = @order.final_price

    if voucher
      return false unless voucher.valid_voucher?(@user)

      final_price = voucher.calculate_discount_price final_price
      voucher.destroy!
      session.delete :voucher_id
    end

    return false unless @user.can_pay? final_price

    @order.update_attribute :final_price, final_price
    @user.pay final_price
  end

  def handle_cancel
    @order.send_confirm_delete_email params[:reason]
    @order.user.charge @order.final_price
  end

  def handle_approved
    return render_failed_update unless handle_payment

    @schedule.update! status: :rent
  end

  def build_order
    @field.order_relationships.build(
      user_id: @user.id,
      status: :pending,
      final_price: calculate_final_price,
      **create_order_params
    )
  end

  def create_schedule
    UnavailableFieldSchedule.create!(
      field_id: @field.id,
      order_field_id: @order.id,
      status: :pending,
      started_date: create_order_params[:date],
      finished_date: create_order_params[:date],
      **create_order_params.except(:date)
    )
  end

  def calculate_final_price
    started_time = get_hour params.dig(:order_field, :started_time)
    finished_time = get_hour params.dig(:order_field, :finished_time)
    return 0 if started_time.nil? || finished_time.nil?

    @field.default_price * (finished_time - started_time)
  end

  def get_hour time
    return if time.nil?

    time = Time.zone.parse(time) if time.is_a? String
    time.hour + (time.min / 60.0).round(1)
  end

  def covert_pagy_to_json pagy
    {
      page: pagy.page,
      next: pagy.next,
      prev: pagy.prev,
      last: pagy.last,
      count: pagy.count
    }
  end
end
