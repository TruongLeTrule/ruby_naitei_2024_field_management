class Admin::UnavailableFieldSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user
  before_action :find_field_by_id
  before_action :find_schedule_by_id, only: %i(edit update destroy)

  def index
    @q = @field.unavailable_field_schedules.ransack params[:q]
    @pagy, @unavailable_field_schedules = pagy @q.result(distinct: true)
  end

  def new
    @schedule = @field.unavailable_field_schedules.build
  end

  def create
    @schedule = build_schedule
    handle_success t(".success") if @schedule.save!
  rescue ActiveRecord::RecordInvalid => e
    handle_fail e.message.split(", ")[0]
  end

  def edit; end

  def update
    if params[:option] == "all"
      @schedule.update! unavailable_field_schedule_params
        .merge(handle_all_day_option)
        .merge(handle_status)
    else
      @schedule.update! unavailable_field_schedule_params.merge(handle_status)
    end
    handle_success t(".success")
  rescue ActiveRecord::RecordInvalid => e
    handle_fail e.message.split(", ")[0]
  end

  def destroy
    @schedule.destroy
    handle_success t(".success")
  end

  private

  def find_schedule_by_id
    return if @schedule = UnavailableFieldSchedule
              .find_by(id: params[:schedule_id])

    flash[:danger] =
      t "admin.unavailable_field_schedules.errors.invalid_schedule"
  end

  def unavailable_field_schedule_params
    params.require(:unavailable_field_schedule)
          .permit UnavailableFieldSchedule::PERMIT_ATTRIBUTE
  end

  def handle_all_day_option
    {started_time: Time.zone.today.beginning_of_day,
     finished_time: Time.zone.today.end_of_day}
  end

  def build_schedule
    if params[:option] == "all"
      @field.unavailable_field_schedules
            .build(unavailable_field_schedule_params
                    .merge(handle_all_day_option)
                    .merge(handle_status))
    else
      @field.unavailable_field_schedules
            .build unavailable_field_schedule_params.merge(handle_status)
    end
  end

  def handle_status
    {status: params.dig(:unavailable_field_schedule, :status).to_i}
  end

  def handle_fail msg
    flash.now[:danger] = msg
    render :new, status: :unprocessable_entity
  end

  def handle_success msg
    flash[:success] = msg
    redirect_to admin_unavailable_field_schedules_path(@field)
  end
end
