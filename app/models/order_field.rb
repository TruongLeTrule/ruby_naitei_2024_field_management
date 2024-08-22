class OrderField < ApplicationRecord
  include PublicActivity::Model
  tracked owner: :user

  CREATE_ATTRIBUTES = %i(date started_time finished_time).freeze
  UPDATE_ATTRIBUTES = %i(status).freeze

  enum status: {pending: 0, approved: 1, cancelling: 2, cancel: 3}

  belongs_to :user
  belongs_to :field
  has_one :unavailable_field_schedule, dependent: :destroy

  validates :date, :started_time, :finished_time, :status, presence: true
  validate :date_is_valid
  validate :times_are_valid
  validate :in_open_time
  validate :not_overlapping
  validate :too_short_time

  scope :search_by_user_name, lambda {|name|
    joins(:user).where("users.name LIKE ?", "%#{name}%") if name.present?
  }
  scope :search_by_field_name, lambda {|name|
    joins(:user).where("fields.name LIKE ?", "%#{name}%") if name.present?
  }
  scope :search_by_date, ->(date){where(date:) if date.present?}
  scope :search_by_status, ->(status){where(status:) if status.present?}
  scope :approved_order, ->{where(approved: true)}
  scope :group_revenue_by_field, (lambda do
    joins(:field).group("fields.name").sum :final_price
  end)
  scope :group_revenue_by_field_type, (lambda do
    joins(field: :field_type).group("field_types.name").sum :final_price
  end)

  ransack_alias :combined_name, :user_name_or_field_name

  ransacker :date_range do
    Arel.sql("DATE(date)")
  end

  after_create :delete_pending

  class << self
    def ransackable_associations _auth_object = nil
      %w(activities field unavailable_field_schedule user)
    end

    def ransackable_attributes _auth_object = nil
      %w(date_range date started_time finished_time final_price status
      created_at updated_at combined_name field_id)
    end

    def group_by_time type
      group_methods = {
        week: :group_by_week,
        month: :group_by_month,
        day: :group_by_day
      }
      grouping_method = group_methods.fetch type
      send(grouping_method, :date).sum :final_price
    end
  end

  def send_delete_order_email
    OrderMailer.delete_order(self).deliver_now
  end

  def send_confirm_delete_email reason
    OrderMailer.confirm_delete(self, reason).deliver_now
  end

  def uncomplete?
    Time.zone.parse("#{date} #{finished_time}") > Time.zone.now
  end

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
      between_date?(schedule) && times_overlap?(schedule)
    end
  end

  def between_date? schedule
    date.between? schedule.started_date, schedule.finished_date
  end

  def too_short_time
    if started_time.nil? ||
       finished_time.nil? ||
       (finished_time.hour - started_time.hour) >= Settings.min_book_time
      return
    end

    errors.add :base, I18n.t("orders.errors.too_short_time")
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

  def delete_pending
    return unless pending?

    DeletePendingOrderJob.perform_in(
      Settings.delete_pending_order_in_minutes.minutes.to_i, id
    )
  end
end
