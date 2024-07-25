class UnavailableFieldSchedule < ApplicationRecord
  enum status: {maintain: 0, pending: 1, rent: 2, closed: 3}

  belongs_to :field
end
