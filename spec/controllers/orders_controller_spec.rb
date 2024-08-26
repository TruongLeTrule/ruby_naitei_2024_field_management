require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  let(:user){create(:user, confirmed_at: Time.current)}
  let(:admin){create(:user, :admin, confirmed_at: Time.current)}
  let(:field){create(:field)}
  let(:order){create(:order_field, user: user, field: field)}

  describe "GET #show" do
    context "when user is admin" do
      before do
        sign_in admin
        get :show, params: {id: order.id, locale: :vi}
      end

      it "successful login" do
        expect(subject.current_user).to eq(admin)
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns the requested order to @order" do
        expect(assigns(:order)).to eq(order)
      end
    end

    context "when user is not admin" do
      before do
        sign_in user
        get :show, params: {id: order.id, locale: :vi}
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #index" do
    let!(:order1) {create(:order_field, status: :pending, user: user, field: field) }
    let!(:order2) {create(:order_field, status: :approved, user: user, field: field) }
    let!(:order3) {create(:order_field, status: :pending, user: user, field: field) }
    context "when user is admin" do
      before do
        sign_in admin
        get :index, params: {locale: :vi}
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns all orders to @orders" do
        expect(assigns(:orders)).to match_array([order1, order2, order3])
      end
    end

    context "when user is not admin" do
      before do
        sign_in user
        get :index, params: {locale: :vi}
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH #update" do
    let(:schedule) {create(:unavailable_field_schedule, order_field: order, field: order.field)}

    context "when updating to approved status" do

      before do
        sign_in user
        allow(controller).to receive(:handle_payment).and_return(true)
        controller.instance_variable_set(:@order, order)
        controller.instance_variable_set(:@schedule, schedule)
        patch :update, params: {id: order.id, order_field: {status: "approved"}, locale: :vi}
      end

      it "updates the order status" do
        expect(order.reload.status).to eq("approved")
      end

      it "updates the schedule status" do
        expect(schedule.reload.status).to eq("rent")
      end

      it "redirects to edit_order_path" do
        expect(response).to redirect_to(edit_order_path(order))
      end
    end

    context "when updating to cancelling status" do
      before do
        sign_in user
        controller.instance_variable_set(:@admin, admin)
        controller.instance_variable_set(:@order, order)
        controller.instance_variable_set(:@schedule, schedule)
        patch :update, params: {id: order.id, order_field: {status: "cancelling"}, locale: :vi}
      end

      it "updates the order status" do
        expect(order.reload.status).to eq("cancelling")
      end

      it "updates the schedule status" do
        expect(schedule.reload.status).to eq("pending")
      end
    end
  end

  describe "GET #edit" do
    context "when user is valid" do
      before do
        sign_in user
        get :edit, params: {id: order.id, locale: :vi}
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns the requested order to @order" do
        expect(assigns(:order)).to eq(order)
      end
    end

    context "when user is not valid" do
      let(:other_user) {create(:user)}
      let(:other_order) {create(:order_field, user: other_user)}

      before do
        sign_in user
        get :edit, params: {id: other_order.id, locale: :vi}
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #export" do
    before do
      sign_in admin
      allow(OrderExportJob).to receive(:perform_async).and_return("job_id_123")
    end

    it "enqueues an OrderExportJob" do
      get :export, params: {format: :json, locale: :vi}
      expect(OrderExportJob).to have_received(:perform_async)
    end

    it "returns a JSON response with job_id" do
      get :export, params: {format: :json, locale: :vi}
      expect(JSON.parse(response.body)).to eq({"jid" => "job_id_123"})
    end
  end

  describe "GET #export_status" do
    before do
      sign_in admin
      allow(Sidekiq::Status).to receive(:get_all).and_return({"status" => "complete", "pct_complete" => 100})
    end

    it "returns a JSON response with job status" do
      get :export_status, params: {job_id: "job_id_123", format: :json, locale: :vi}
      expect(JSON.parse(response.body)).to eq({"status" => "complete", "percentage" => 100})
    end
  end

  describe "GET #export_download" do
    before do
      sign_in admin
      allow(controller).to receive(:send_file)
    end

    it "sends the exported file" do
      get :export_download, params: {job_id: "job_id_123", format: :xlsx, locale: :vi}
      expect(controller).to have_received(:send_file).with(Rails.root.join("public", "data", "orders_job_id_123.xlsx"))
    end
  end

  describe "#handle_payment" do
    let(:voucher) {create(:voucher, user: user)}

    before do
      sign_in user
      controller.instance_variable_set(:@order, order)
      allow(Voucher).to receive(:find_by).and_return(voucher)
      allow(voucher).to receive(:valid_voucher?).and_return(true)
      allow(voucher).to receive(:calculate_discount_price).and_return(90)
      allow(user).to receive(:can_pay?).and_return(true)
      allow(user).to receive(:pay)
      session[:voucher_id] = voucher
    end

    it "applies voucher discount when valid" do
      expect(controller.send(:handle_payment)).to be true
      expect(order.reload.final_price).to eq(90)
    end

    it "charges the user" do
      allow(controller).to receive(:current_user).and_return(user)
      controller.send(:handle_payment)
      expect(user).to have_received(:pay).with(90)
    end

    context "when voucher is invalid" do
      before do
        allow(voucher).to receive(:valid_voucher?).and_return(false)
      end

      it "returns false" do
        expect(controller.send(:handle_payment)).to be false
      end
    end

    context "when user cannot pay" do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user).to receive(:can_pay?).and_return(false)
      end

      it "returns false" do
        expect(controller.send(:handle_payment)).to be false
      end
    end
  end

  describe "#handle_cancel" do
    before do
      controller.instance_variable_set(:@order, order)
      allow(order).to receive(:send_confirm_delete_email)
      allow(order.user).to receive(:charge)
    end

    it "sends confirmation email" do
      controller.send(:handle_cancel)
      expect(order).to have_received(:send_confirm_delete_email).with(nil)
    end

    it "charges the user" do
      controller.send(:handle_cancel)
      expect(order.user).to have_received(:charge).with(order.final_price)
    end
  end
end
