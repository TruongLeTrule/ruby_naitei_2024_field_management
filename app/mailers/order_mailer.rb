class OrderMailer < ApplicationMailer
  include UsersHelper

  def delete_order order
    @order = order
    @admin = admin
    mail to: @admin.email, subject: t("order_mailer.delete_order.subject")
  end

  def confirm_delete order
    @order = order
    mail to: @order.user.email,
         subject: t("order_mailer.confirm_delete.subject")
  end
end
