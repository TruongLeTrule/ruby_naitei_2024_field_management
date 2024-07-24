class Voucher < ApplicationRecord
  enum type: {percent: 0, price: 1}

  belongs_to :user
end
