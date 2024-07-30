class OrderField < ApplicationRecord
  CREATE_ATTRIBUTES = %i(date started_time finished_time).freeze
  UPDATE_ATTRIBUTES = %i(status).freeze

  enum status: {pending: 0, approved: 1, cancel: 2}

  belongs_to :user
  belongs_to :field
  has_one :unavailable_field_schedule, dependent: :destroy

  validates :date, :started_time, :finished_time, :status, presence: true
  validate :date_is_valid
  validate :times_are_valid
  validate :in_open_time
  validate :not_overlapping

  private

  def date_is_valid
    return unless date.nil? || date < Time.zone.today

    errors.add :date, I18n.t("orders.errors.present_date")
  end

  def times_are_valid
    return if missing_times?

    validate_start_time
    validate_time_order
  end

  def in_open_time
    return if missing_times_or_field?

    field_open_time = field.open_time || Time.zone.local(2000, 1, 1, 0, 0, 0)
    field_close_time = field.close_time ||
                       Time.zone.local(2000, 1, 1, 23, 59, 59)

    if started_time.strftime("%H:%M") < field_open_time.strftime("%H:%M") ||
       finished_time.strftime("%H:%M") > field_close_time.strftime("%H:%M")
      errors.add :base, I18n.t("orders.errors.open_time")
    end
  end

  def not_overlapping
    return if missing_times_or_field?

    overlapping_schedule = find_overlapping_schedule

    return unless overlapping_schedule

    errors.add :base, I18n.t("orders.errors.not_overlapped")
  end

  def missing_times?
    started_time.nil? || finished_time.nil?
  end

  def validate_start_time
    return unless date == Time.zone.today && started_time_in_past?

    errors.add :base, I18n.t("orders.errors.present_time")
  end

  def started_time_in_past?
    started_time.strftime("%H:%M") < Time.zone.now.strftime("%H:%M")
  end

  def validate_time_order
    unless started_time.strftime("%H:%M") > finished_time.strftime("%H:%M")
      return
    end

    errors.add :base, I18n.t("orders.errors.finished_time")
  end

  def missing_times_or_field?
    missing_times? || field.nil?
  end

  def find_overlapping_schedule
    field.unavailable_field_schedules.find do |schedule|
      same_date?(schedule) && times_overlap?(schedule)
    end
  end

  def same_date? schedule
    schedule.date == date
  end

  def times_overlap? schedule
    order_started_time = started_time.strftime("%H:%M")
    order_finished_time = finished_time.strftime("%H:%M")
    schedule_started_time = schedule.started_time.strftime("%H:%M")
    schedule_finished_time = schedule.finished_time.strftime("%H:%M")

    current_range = order_started_time...order_finished_time
    schedule_range = schedule_started_time...schedule_finished_time

    current_range.overlaps?(schedule_range) ||
      schedule_range.cover?(current_range)
  end
end
