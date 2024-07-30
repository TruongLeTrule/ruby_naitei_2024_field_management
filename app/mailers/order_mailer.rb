class OrderMailer < ApplicationMailer
  include UsersHelper

  def delete_order order
    @order = order
    @admin = admin
    mail to: @admin.email, subject: t("order_mailer.delete_order.subject")
  end
end
