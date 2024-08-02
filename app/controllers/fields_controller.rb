class FieldsController < ApplicationController
  before_action :find_field_by_id, only: %i(show new_order create_order)
  before_action :logged_in_user, only: %i(new_order create_order)

  def show; end

  def index
    @pagy, @fields = pagy Field.name_like(params[:search]).order_by(:created_at)
  end

  def new_order
    @order = OrderField.new
  end

  def create_order
    ActiveRecord::Base.transaction do
      @order = build_order
      @order.save!
      @schedule = create_schedule
      successful_create
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
    failed_create
  end

  private
  def order_params
    params.require(:order_field).permit OrderField::CREATE_ATTRIBUTES
  end

  def successful_create
    flash[:success] = t "fields.create_order.success"
    redirect_to edit_order_path(@order)
  end

  def failed_create
    flash[:danger] = t "fields.create_order.failed"
    redirect_to new_order_path(@order), status: :unprocessable_entity
  end

  def invalid_field
    flash[:danger] = t "fields.errors.invalid"
    redirect_to root_path
  end

  def build_order
    @field.order_relationships.build(
      user_id: current_user.id,
      status: :pending,
      final_price: get_final_price,
      **order_params
    )
  end

  def create_schedule
    UnavailableFieldSchedule.create!(
      field_id: @field.id,
      order_field_id: @order.id,
      status: :pending,
      **order_params
    )
  end

  def get_final_price
    started_time = Time.zone.parse params.dig(:order_field, :started_time)
    finished_time = Time.zone.parse params.dig(:order_field, :finished_time)
    @field.default_price * (finished_time.hour - started_time.hour)
  end
end
