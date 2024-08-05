class FieldsController < ApplicationController
  before_action :find_field_by_id, except: %i(create new index)
  before_action :logged_in_user, only: %i(new_order create_order)
  before_action :admin_user, only: %i(new create edit update destroy)
  before_action :set_default_params, only: :index

  def show; end

  def edit; end

  def index
    type = params[:type] == "all" ? nil : params[:type]

    @pagy, @fields = pagy Field.order_by(params[:order], params[:sort])
                               .name_like(params[:search])
                               .field_type(type)
                               .most_rated
  end

  def new
    @field = Field.new
  end

  def create
    @field = Field.new field_params
    @field.image.attach params.dig(:field, :image)

    if @field.save
      flash[:success] = t ".success"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params.dig(:field, :image).present?
      @field.image.attach(params.dig(:field, :image))
    end

    if @field.update field_params
      flash.now[:success] =
        t ".success", deep_intepolation: true, field: @field.name
      render :edit, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @field.has_any_uncompleted_order?
      flash.now[:danger] = t ".has_uncompleted_order"
      return render :edit, status: :see_other
    end

    @field.destroy
    flash[:success] = t ".success", deep_intepolation: true, field: @field.name
    redirect_to root_path, status: :see_other
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
  def field_params
    params.require(:field).permit Field::CREATE_ATTRIBUTES
  end

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
      **order_params
    )
  end

  def calculate_final_price
    started_time = Time.zone.parse params.dig(:order_field, :started_time)
    finished_time = Time.zone.parse params.dig(:order_field, :finished_time)
    return 0 if started_time.nil? || finished_time.nil?

    @field.default_price * (finished_time.hour - started_time.hour)
  end

  def set_default_params
    return unless request.query_parameters.empty?

    redirect_to fields_path(type: :all, most_rated: true)
  end
end
