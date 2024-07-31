class UnavailableFieldSchedulesController < ApplicationController
  def index
    @field = Field.find_by id: params[:field_id]
    @unavailable_field_schedules = @field.unavailable_field_schedules.date(
      params[:date]
    )
  end
end
