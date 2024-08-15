module UnavailableFieldSchedulesHelper
  def all_statuses
    UnavailableFieldSchedule.statuses.keys.map do |status|
      [
        t("activerecord.attributes." \
          "unavailable_field_schedule.statuses.#{status}"),
          UnavailableFieldSchedule.statuses[status]
      ]
    end
  end

  def first_status
    UnavailableFieldSchedule.statuses.first[1]
  end

  def time_options
    [
      [t("admin.unavailable_field_schedules.form.all_day"), "all"],
      [t("admin.unavailable_field_schedules.form.choose_time"),
"include_time"]
    ]
  end

  def header_keys
    %i(# started_date finished_date started_time
       finished_time created_at status action)
  end

  def render_keys
    %i(display_started_date display_finished_date display_started_time
       display_finished_time display_created_at display_status action)
  end

  def handle_render_schedules schedules
    schedules.map do |schedule|
      format_date schedule
      format_time schedule
      schedule.display_status = resolve_status_to_html schedule
      schedule.display_created_at = schedule.created_at
                                            .strftime Settings.date_time_format
      schedule.action = resolve_action_to_html schedule
      schedule
    end
  end

  private

  def format_time schedule
    schedule.display_started_time = schedule.started_time
                                            .strftime Settings.time_format
    schedule.display_finished_time = schedule.finished_time
                                             .strftime Settings.time_format
  end

  def format_date schedule
    schedule.display_started_date = schedule.started_date
                                            .strftime Settings.date_format
    schedule.display_finished_date = schedule.finished_date
                                             .strftime Settings.date_format
  end

  def resolve_status_to_html schedule
    case schedule.status
    when "maintain"
      content_tag :span,
                  schedule.translate_enum(:status, schedule.status),
                  class: "text-light-red"
    when "closed"
      content_tag :span,
                  schedule.translate_enum(:status, schedule.status),
                  class: "text-red-500"
    when "rent"
      content_tag :span,
                  schedule.translate_enum(:status, schedule.status),
                  class: "text-primary"
    else
      schedule.translate_enum :status, schedule.status
    end
  end

  def resolve_action_to_html schedule
    link_to t("admin.unavailable_field_schedules.index.view"),
            edit_admin_unavailable_field_schedule_path(schedule.field,
                                                       schedule),
            class: "hover:underline text-blue-600"
  end
end
