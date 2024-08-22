require "rails_helper"

RSpec.describe OrderField, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:field) }
    it { should have_one(:unavailable_field_schedule).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:started_time) }
    it { should validate_presence_of(:finished_time) }
    it { should validate_presence_of(:status) }

    it { should define_enum_for(:status).with_values(pending: 0, approved: 1, cancelling: 2, cancel: 3) }

    describe "custom validations" do
      let(:field) { create(:field, open_time: "08:00", close_time: "22:00") }
      let(:order_field) { build(:order_field, field: field) }

      it "validates date is not in the past" do
        order_field.date = Date.yesterday
        expect(order_field).not_to be_valid
        expect(order_field.errors[:date]).to include(I18n.t("orders.errors.present_date"))
      end

      it "validates times are within field open hours" do
        order_field.started_time = "07:00"
        order_field.finished_time = "23:00"
        expect(order_field).not_to be_valid
        expect(order_field.errors[:base]).to include(I18n.t("orders.errors.open_time"))
      end

      it "validates booking duration is not too short" do
        order_field.started_time = "14:00"
        order_field.finished_time = "14:30"
        expect(order_field).not_to be_valid
        expect(order_field.errors[:base]).to include(I18n.t("orders.errors.too_short_time"))
      end

      it "validates no overlapping schedules" do
        create(:unavailable_field_schedule, field: field, started_date: Date.tomorrow, finished_date: Date.tomorrow, started_time: "10:00", finished_time: "12:00")
        order_field.date = Date.tomorrow
        order_field.started_time = "11:00"
        order_field.finished_time = "13:00"
        expect(order_field).not_to be_valid
        expect(order_field.errors[:base]).to include(I18n.t("orders.errors.not_overlapped"))
      end
    end
  end

  describe "scopes" do
    let!(:user1) { create(:user, name: "John Doe") }
    let!(:user2) { create(:user, name: "Jane Smith") }
    let!(:field1) { create(:field, name: "Football Field") }
    let!(:field2) { create(:field, name: "Basketball Court") }
    let!(:order1) { create(:order_field, user: user1, field: field1, date: Date.tomorrow, status: :pending) }
    let!(:order2) { create(:order_field, user: user2, field: field2, date: Date.today + 2.days, status: :approved) }

    it "searches by user name" do
      expect(OrderField.search_by_user_name("John")).to include(order1)
      expect(OrderField.search_by_user_name("John")).not_to include(order2)
    end

    it "searches by field name" do
      expect(OrderField.search_by_field_name("Football")).to include(order1)
      expect(OrderField.search_by_field_name("Football")).not_to include(order2)
    end

    it "searches by date" do
      expect(OrderField.search_by_date(Date.tomorrow)).to include(order1)
      expect(OrderField.search_by_date(Date.tomorrow)).not_to include(order2)
    end

    it "searches by status" do
      expect(OrderField.search_by_status(:pending)).to include(order1)
      expect(OrderField.search_by_status(:pending)).not_to include(order2)
    end

    it "returns approved orders" do
      expect(OrderField.approved_order).to include(order2)
      expect(OrderField.approved_order).not_to include(order1)
    end
  end

  describe "instance methods" do
    let(:field) { create(:field, name: "Chelsea") }
    let(:order_field) { create(:order_field ,field: field) }

    it "#send_delete_order_email" do
      expect(OrderMailer).to receive(:delete_order).with(order_field).and_return(double(deliver_now: true))
      order_field.send_delete_order_email
    end

    it "#send_confirm_delete_email" do
      reason = "Test reason"
      expect(OrderMailer).to receive(:confirm_delete).with(order_field, reason).and_return(double(deliver_now: true))
      order_field.send_confirm_delete_email(reason)
    end

    it "#uncomplete?" do
      order_field.date = Date.today

      order_field.finished_time = 1.hour.after
      expect(order_field.uncomplete?).to be true

      order_field.finished_time = 1.hour.ago
      expect(order_field.uncomplete?).to be false
    end
  end

  describe "callbacks" do
    it "schedules DeletePendingOrderJob after create for pending orders" do
      field = create(:field, name: "ManU")
      order_field = build(:order_field, status: :pending, field: field)
      expect(DeletePendingOrderJob).to receive(:perform_in).with(Settings.delete_pending_order_in_minutes.minutes.to_i, kind_of(Integer))
      order_field.save
    end

    it "does not schedule DeletePendingOrderJob for non-pending orders" do
      field = create(:field, name: "ManC")
      order_field = build(:order_field, status: :approved, field: field)
      expect(DeletePendingOrderJob).not_to receive(:perform_in)
      order_field.save
    end
  end
end
