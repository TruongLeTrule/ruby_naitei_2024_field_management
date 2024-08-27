class AdminMailer < ApplicationMailer
  include UsersHelper

  def send_report file_path
    attachments["report.xlsx"] = File.read file_path
    @admin = admin
    mail to: @admin.email, subject: t(".subject")
  end
end
