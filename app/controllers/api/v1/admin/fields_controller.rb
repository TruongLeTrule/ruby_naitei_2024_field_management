class Api::V1::Admin::FieldsController < ApplicationController
  before_action :load_field, except: %i(index create)
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @q = Field.ransack params[:q]
    @pagy, @fields = pagy @q.result.includes(:field_type, :order_relationships)

    render json: {
      fields: @fields,
      pagination: covert_pagy_to_json(@pagy)
    }, status: :ok
  end

  def create
    @field = Field.new field_params
    @field.image.attach params.dig(:field, :image)

    if @field.save
      render json: {
        message: t("admin.fields.create.success"),
        field: @field.as_json
      }, status: :created
    else
      render json: {errors: @field.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def edit
    render json: {field: @field}, status: :ok
  end

  def update
    if params.dig(:field, :image).present?
      @field.image.attach(params.dig(:field, :image))
    end

    if @field.update field_params
      render json: {
        message: t("admin.fields.update.success", deep_intepolation: true,
field: @field.name),
        field: @field.as_json
      }, status: :ok
    else
      render json: {errors: @field.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def destroy
    if @field.has_any_uncompleted_order?
      return render json: {
        message: t("admin.fields.destroy.has_uncompleted_order")
      }, status: :see_other
    end

    @field.destroy
    render json: {
      message: t("admin.fields.destroy.success", deep_intepolation: true,
field: @field.name),
      field: @field.as_json
    }, status: :ok
  end

  private

  def field_params
    params.require(:field).permit Field::CREATE_ATTRIBUTES
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

  def load_field
    return if @field = Field.find_by(id: params[:id])

    render json: {
      message: t("fields.errors.invalid")
    }, status: :not_found
  end
end
