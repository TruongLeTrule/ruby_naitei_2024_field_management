class VouchersController < ApplicationController
  before_action :logged_in_user, :find_order_by_id, :find_voucher_by_id

  def apply
    @price = @voucher.calculate_discount_price @order.final_price

    session[:voucher_id] = @voucher.id

    respond_to do |format|
      format.html{redirect_to edit_order_path(@order)}
      format.turbo_stream
    end
  end

  private

  def find_voucher_by_id
    @voucher = Voucher.find_by id: params[:voucher_id] || session[:voucher_id]
    return if @voucher.valid_voucher? current_user

    flash[:danger] = t ".invalid_voucher"
    redirect_to root_path
  end
end
