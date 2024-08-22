class DeletePendingOrderJob
  include Sidekiq::Job

  def perform order_id
    order = OrderField.find_by id: order_id
    order.destroy if order&.pending?
  end
end
