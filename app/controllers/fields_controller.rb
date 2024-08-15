class FieldsController < ApplicationController
  before_action :find_field_by_id, except: :index
  before_action :set_default_params, only: :index

  def show
    @pagy, @ratings = pagy @field.ratings.lastest
    create_action(current_user, :viewed, @field)
  end

  def index
    @pagy, @fields = pagy Field.most_rated(params[:most_rated])
                               .order_by(params[:order], params[:sort])
                               .name_like(params[:search])
                               .field_type(params[:type])
                               .favourite_by_current_user(
                                 find_favourite_field_ids
                               )
  end

  def new_order
    authorize! :create, OrderField
    @order = OrderField.new
  end

  def create_order
    authorize! :create, OrderField
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
      final_price: calculate_final_price,
      **order_params
    )
  end

  def create_schedule
    UnavailableFieldSchedule.create!(
      field_id: @field.id,
      order_field_id: @order.id,
      status: :pending,
      started_date: order_params[:date],
      finished_date: order_params[:date],
      **order_params.except(:date)
    )
  end

  def calculate_final_price
    started_time = get_hour Time.zone.parse(params.dig(:order_field,
                                                       :started_time))
    finished_time = get_hour Time.zone.parse(params.dig(:order_field,
                                                        :finished_time))
    return 0 if started_time.nil? || finished_time.nil?

    @field.default_price * (finished_time - started_time)
  end

  def set_default_params
    return unless request.query_parameters.empty?

    redirect_to fields_path(type: :all, most_rated: true)
  end

  def find_favourite_field_ids
    current_user&.favourite_field_ids if params[:favourite]
  end

  def get_hour time
    return if time.nil?

    time.hour + (time.min / 60.0).round(1)
  end
end
