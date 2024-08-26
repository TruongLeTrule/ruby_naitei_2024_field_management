class Api::V1::FieldsController < ApplicationController
  before_action :load_field, except: :index
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @pagy, @fields = pagy(if params[:favourite]
                            handle_favourite_fields
                          else
                            handle_normal_fields
                          end)

    serialized_fields = ActiveModelSerializers::SerializableResource.new(
      @fields,
      each_serializer: FieldSerializer
    ).as_json
    serialized_field_types = ActiveModelSerializers::SerializableResource.new(
      FieldType.all,
      each_serializer: FieldTypeSerializer
    ).as_json

    render json: {
      fields: serialized_fields,
      field_types: serialized_field_types,
      pagination: covert_pagy_to_json(@pagy)
    }, status: :ok
  end

  def show
    @pagy, @ratings = pagy @field.ratings.lastest
    create_action(current_user, :viewed, @field)

    serialized_ratings = ActiveModelSerializers::SerializableResource.new(
      @ratings,
      each_serializer: RatingSerializer
    ).as_json

    render json: {
      field: FieldSerializer.new(@field),
      ratings: serialized_ratings,
      pagination: covert_pagy_to_json(@pagy)
    }, status: :ok
  end

  private

  def load_field
    return if @field = Field.find_by(id: params[:id])

    render json: {
      message: t("fields.errors.invalid")
    }, status: :not_found
  end

  def handle_normal_fields
    Field.most_rated(params[:most_rated])
         .order_by(params[:order], params[:sort])
         .name_like(params[:search])
         .field_type(params[:type])
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
