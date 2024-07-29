module OrdersHelper
  def handle_price order
    order.final_price || Settings.default_price
  end
end
