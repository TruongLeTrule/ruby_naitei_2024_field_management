class UnavailableFieldSchedule < ApplicationRecord
  PERMIT_ATTRIBUTE = %i(status started_date finished_date
started_time finished_time field_id).freeze

  enum status: {maintain: 0, pending: 1, rent: 2, closed: 3}

  attr_accessor :display_status, :display_started_time,
                :display_finished_time, :display_created_at,
                :display_started_date, :display_finished_date,
                :action

  belongs_to :field
  belongs_to :order_field, optional: true

  validates :status, :started_time, :finished_time, :started_date,
            :finished_date, presence: true
  validate :validate_future_date
  validate :validate_time_range
  validate :validate_date_range
  validate :order_existing

  scope :am, ->{where "EXTRACT(HOUR FROM started_time) < 12"}
  scope :pm, (lambda do
    where(
      "EXTRACT(HOUR FROM started_time) >= 12 " \
      "OR EXTRACT(HOUR FROM finished_time) >= 12"
    )
  end)
  scope :within_date_range, lambda {|current_date|
    where("started_date <= ? AND finished_date >= ?",
          current_date, current_date)
  }

  class << self
    def ransackable_associations _auth_object = nil
      %w(field order_field)
    end

    def ransackable_attributes _auth_object = nil
      %w(created_at field_id finished_date finished_time
         started_date started_time status)
    end
  end

  private

  def future_date? date
    date >= Time.zone.today
  end

  def validate_future_date
    return if future_date?(started_date) &&
              future_date?(finished_date)

    errors.add :base,
               I18n.t("admin.unavailable_field_schedules.errors" \
                      ".date_should_be_future")
  end

  def validate_time_range
    if finished_time.nil? || started_time.nil? || finished_time > started_time
      return
    end

    errors.add :base,
               I18n.t("admin.unavailable_field_schedules.errors." \
                      "finish_time_smaller_than_start")
  end

  def validate_date_range
    return if finished_date.nil? || started_date.nil? ||
              finished_date >= started_date

    errors.add :base,
               I18n.t("admin.unavailable_field_schedules.errors" \
                      ".finish_date_smaller_than_start")
  end

  def order_existing
    OrderField.ransack(date_range_gteq: started_date,
                       date_range_lteq: finished_date).result.each do |order|
      next unless time_colapse? order

      errors.add :base,
                 I18n.t("admin.unavailable_field_schedules.errors" \
                        ".order_existing")
    end
  end

  def time_colapse? order
    return if finished_time.nil? || started_time.nil?

    order.started_time > started_time && order.finished_time < finished_time
  end
end
