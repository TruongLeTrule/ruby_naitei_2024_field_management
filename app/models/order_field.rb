class OrderField < ApplicationRecord
  CREATE_ATTRIBUTES = %i(date started_time finished_time).freeze
  UPDATE_ATTRIBUTES = %i(status).freeze

  enum status: {pending: 0, approved: 1, cancelling: 2, cancel: 3}

  belongs_to :user
  belongs_to :field
  has_one :unavailable_field_schedule, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy

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

  after_create :create_activity
  after_update :update_activity

  def send_delete_order_email
    OrderMailer.delete_order(self).deliver_now
  end

  def send_confirm_delete_email
    OrderMailer.confirm_delete(self).deliver_now
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
      same_date?(schedule) && times_overlap?(schedule)
    end
  end

  def same_date? schedule
    schedule.date == date
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

  def create_activity
    create_action(user, :created, self)
  end

  def update_activity
    create_action(user, :updated, self)
  end
end
