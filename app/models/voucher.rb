class Voucher < ApplicationRecord
  enum voucher_type: {percent: 0, price: 1}

  belongs_to :user

  scope :ordered_by_type_amount, ->{order :voucher_type, :amount}

  def get_discount_price current_price
    if voucher_type == "percent"
      current_price * (1 - amount)
    else
      current_price - amount
    end
  end

  def valid? current_user
    user == current_user
  end
end
