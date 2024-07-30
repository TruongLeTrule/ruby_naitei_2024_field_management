require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "#delete_order" do
    let(:user) { User.new(id: 2, name: "John Doe", email: "john@example.com") }
    let(:field) { Field.new(id: 1, name: "Soccer Field") }
    let(:order) { OrderField.new(id: 1, user_id: user.id, field_id: field.id) }
    let(:admin) { User.new(name: "admin", email: "admin@gmail.com") }
    let(:mail) { OrderMailer.delete_order(order) }

    before do
      allow(order).to receive(:user).and_return(user)
      allow(order).to receive(:field).and_return(field)
      allow_any_instance_of(OrderMailer).to receive(:admin).and_return(admin)
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("order_mailer.delete_order.subject"))
      expect(mail.to).to eq([admin.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(admin.name)
      expect(mail.body.encoded).to match(order.id.to_s)
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(field.name)
    end
  end
end
