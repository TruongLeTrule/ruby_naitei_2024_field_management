class UnavailableFieldSchedule < ApplicationRecord
  enum status: {maintain: 0, pending: 1, rent: 2, closed: 3}

  belongs_to :field
  belongs_to :order_field, optional: true

  scope :am, ->{where "EXTRACT(HOUR FROM started_time) < 12"}
  scope :pm, (lambda do
    where(
      "EXTRACT(HOUR FROM started_time) >= 12 " \
      "OR EXTRACT(HOUR FROM finished_time) >= 12"
    )
  end)
  scope :date, ->(date){where date:}
end
