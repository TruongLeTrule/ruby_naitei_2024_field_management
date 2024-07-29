class FieldsController < ApplicationController
  before_action :find_field_by_id, only: :show

  def show; end

  def index
    @pagy, @fields = pagy Field.name_like(params[:search]).order_by(:created_at)
  end

  private
  def find_field_by_id
    return if @field = Field.find_by(id: params[:id])

    flash[:danger] = t "fields.errors.invalid"
    redirect_to root_path
  end
end
