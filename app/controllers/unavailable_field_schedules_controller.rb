class UnavailableFieldSchedulesController < ApplicationController
  before_action :find_field_by_id

  def index
    @unavailable_field_schedules = @field.unavailable_field_schedules
                                         .within_date_range params[:date]
  end
end
