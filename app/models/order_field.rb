class OrderField < ApplicationRecord
  enum status: {pending: 0, approved: 1, cancel: 2}

  belongs_to :user
  belongs_to :field
end
