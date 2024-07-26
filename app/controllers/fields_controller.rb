class FieldsController < ApplicationController
  def index
    @pagy, @fields = pagy Field.name_like(params[:search]).order_by(:created_at)
  end
end
