class SendReportToAdminJob
  include Sidekiq::Job

  def perform
    orders = OrderField.ransack(date_gt: Time.zone.today.beginning_of_month,
                                date_lt: Time.zone.today.end_of_month)
                       .result(distance: true)
                       .includes(:user, :field)
    OrderExportJob.new.perform orders.as_json(include: [:user, :field])

    file_path = Rails.root.join("public/data/orders.xlsx").to_s
    AdminMailer.send_report(file_path).deliver_now

    File.delete(file_path) if File.exist?(file_path)
  end
end
