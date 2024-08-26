require "rails_helper"

RSpec.describe Field, type: :model do
  describe "associations" do
    it{should belong_to(:field_type)}

    describe "one-many" do
      it{should have_many(:ratings).dependent(:destroy)}
      it{should have_many(:unavailable_field_schedules).dependent(:destroy)}
    end

    describe "one-one" do
      it{should have_one_attached(:image)}
    end

    describe "many-many" do
      it{should have_many(:order_relationships).dependent(:destroy)}
      it{should have_many(:ordered_users).through(:order_relationships).class_name(User.name)}
      it{should have_many(:favourite_relationships).dependent(:destroy)}
      it{should have_many(:favourite_users).through(:favourite_relationships).class_name(User.name)}
    end
  end

  describe "validations" do
    subject{create :field}

    describe "presence of required attributes" do
      it{should validate_presence_of(:name)}
      it{should validate_presence_of(:field_type_id)}
      it{should validate_presence_of(:default_price)}
      it{should validate_presence_of(:open_time)}
      it{should validate_presence_of(:close_time)}
    end

    describe "uniqueness of name in each field type" do
      it{should validate_uniqueness_of(:name).scoped_to(:field_type_id).case_insensitive}
    end

    describe "length of description less than #{Settings.max_length_255}" do
      it{should validate_length_of(:description).is_at_most(Settings.max_length_255)}
    end

    describe "image attachment" do
      let(:valid_image){fixture_file_upload("attachable_field_img.jpg", "image/jpeg")}
      let(:invalid_format_image){fixture_file_upload("invalid_format_img.txt", "text/plain")}
      let(:invalid_large_size_image){fixture_file_upload("invalid_large_size_img.jpg", "image/jpeg")}

      context "with size <= #{Settings.max_img_size}mb and format in '#{Settings.image_format}'" do
        before{subject.image.attach valid_image}
        it{expect(subject).to be_valid}
      end

      context "with format not in '#{Settings.image_format}'" do
        before{subject.image.attach invalid_format_image}

        it do
          expect(subject).not_to be_valid
          expect(subject.errors[:image]).to include(I18n.t("fields.errors.invalid_img_format"))
        end
      end

      context "with size too large (> #{Settings.max_img_size}mb)" do
        before{subject.image.attach invalid_large_size_image}

        it do
          expect(subject).not_to be_valid
          expect(subject.errors[:image]).to include(I18n.t("fields.errors.too_large_img_size"))
        end
      end
    end

    describe "appopriate open time and close time" do
      context "when open time < close time" do
        before do
          subject.open_time = "08:00"
          subject.close_time = "21:00"
        end

        it{expect(subject).to be_valid}
      end

      context "when open time > close time" do
        before do
          subject.open_time = "08:00"
          subject.close_time = "07:00"
        end

        it do
          expect(subject).not_to be_valid
          expect(subject.errors[:base]).to include(I18n.t("fields.errors.valid_time"))
        end
      end

      context "when open time = close time" do
        before do
          subject.open_time = "08:00"
          subject.close_time = "08:00"
        end

        it do
          expect(subject).not_to be_valid
          expect(subject.errors[:base]).to include(I18n.t("fields.errors.valid_time"))
        end
      end
    end
  end

  describe ".name_like" do
    let(:matching_field){create :field, name: "Real Marid"}
    let(:non_matching_field){create :field, name: "Barcelona"}

    context "when a matching name is provided" do
      it "returns records that match the name pattern" do
        expect(Field.name_like("Real Marid")).to include(matching_field)
        expect(Field.name_like("Real Marid")).not_to include(non_matching_field)
      end
    end

    context "when a non-matching name is provided" do
      it{expect(Field.name_like("Aletico Marid")).to be_empty}
    end

    context "when name is not provided" do
      it "returns all records" do
        expect(Field.name_like("")).to include(matching_field, non_matching_field)
      end
    end
  end

  describe ".order_by" do
    let(:field_type_1){create :field_type}
    let(:field_type_2){create :field_type}
    let!(:field_1){create :field, default_price: 100, name: "Field #1",
                                  description: "Content #1", open_time: "08:00",
                                  close_time: "20:00", field_type: field_type_1}
    let!(:field_2){create :field, default_price: 200, name: "Field #2",
                                  description: "Content #2", open_time: "09:00",
                                  close_time: "21:00", field_type: field_type_2}

    context "when ordering by created_at" do
      it "orders by created_at in ascending order" do
        expect(Field.order_by :created_at, :asc).to eq([field_1, field_2])
      end

      it "orders by created_at in descending order" do
        expect(Field.order_by :created_at, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by updated_at" do
      it "orders by updated_at in ascending order" do
        expect(Field.order_by :updated_at, :asc).to eq([field_1, field_2])
      end

      it "orders by updated_at in descending order" do
        expect(Field.order_by :updated_at, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by default_price" do
      it "orders by default_price in ascending order" do
        expect(Field.order_by :default_price, :asc).to eq([field_1, field_2])
      end

      it "orders by default_price in descending order" do
        expect(Field.order_by :default_price, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by name" do
      it "orders by name in ascending order" do
        expect(Field.order_by :name, :asc).to eq([field_1, field_2])
      end

      it "orders by name in descending order" do
        expect(Field.order_by :name, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by description" do
      it "orders by description in ascending order" do
        expect(Field.order_by :description, :asc).to eq([field_1, field_2])
      end

      it "orders by description in descending order" do
        expect(Field.order_by :description, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by open_time" do
      it "orders by open_time in ascending order" do
        expect(Field.order_by :open_time, :asc).to eq([field_1, field_2])
      end

      it "orders by open_time in descending order" do
        expect(Field.order_by :open_time, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by close_time" do
      it "orders by close_time in ascending order" do
        expect(Field.order_by :close_time, :asc).to eq([field_1, field_2])
      end

      it "orders by close_time in descending order" do
        expect(Field.order_by :close_time, :desc).to eq([field_2, field_1])
      end
    end

    context "when ordering by field_type_id" do
      it "orders by field_type_id in ascending order" do
        expect(Field.order_by :field_type_id, :asc).to eq([field_1, field_2])
      end

      it "orders by field_type_id in descending order" do
        expect(Field.order_by :field_type_id, :desc).to eq([field_2, field_1])
      end
    end

    context "when no argument is provided" do
      it "orders by created_at in ascending order by default" do
        expect(Field.order_by).to eq([field_1, field_2])
      end
    end

    context "when one argument is provided" do
      it "orders by provided argument in ascending order by default" do
        expect(Field.order_by :close_time).to eq([field_1, field_2])
      end
    end

    context "when provided attribute is invalid" do
      it "raises an ActiveRecord::StatementInvalid error" do
        expect{Field.order_by(:invalid_attribute).to_a}.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context "when provided direction is invalid" do
      it "raises an ArgumentError error" do
        expect{Field.order_by(:name, :up)}.to raise_error(ArgumentError)
      end
    end
  end

  describe ".most_rated" do
    let(:field_1){create :field}
    let(:field_2){create :field}
    let(:rating_1){create :rating, field: field_1, rating: 1.0}
    let(:rating_2){create :rating, field: field_1, rating: 2.0}
    let(:rating_3){create :rating, field: field_2, rating: 4.0}
    let(:rating_4){create :rating, field: field_2, rating: 5.0}

    context "when true provided" do
      it "orders by average rating in descending order" do
        expect(Field.most_rated true).to eq([field_2, field_1])
      end
    end

    context "when falsy or no argument provided" do
      it "returns in default order" do
        expect(Field.most_rated false).to eq([field_1, field_2])
        expect(Field.most_rated).to eq([field_1, field_2])
      end
    end
  end

  describe ".field_type" do
    let(:field_type_1){create :field_type}
    let(:field_type_2){create :field_type}
    let(:field_1){create :field, field_type: field_type_1}
    let(:field_2){create :field, field_type: field_type_1}
    let(:field_3){create :field, field_type: field_type_2}

    context "when field_type_id provided" do
      it "returns fields in this field type" do
        expect(Field.field_type field_type_1.id).to include(field_1, field_2)
        expect(Field.field_type field_type_2.id).to include(field_3)
      end
    end

    context "when 'all' or no argument provided" do
      it "returns all fields" do
        expect(Field.field_type "all").to include(field_1, field_2, field_3)
        expect(Field.field_type).to include(field_1, field_2, field_3)
      end
    end
  end

  describe ".favourite_by_current_user" do
    let(:user){create :user}
    let(:field_1){create :field}
    let(:field_2){create :field}
    let(:field_3){create :field}

    before do
      user.add_favourite_field [field_1, field_2]
    end

    context "when current user favourite fields ids provied" do
      it "returns fields current user added to favourite list" do
        expect(Field.favourite_by_current_user user.favourite_field_ids)
        .to include(field_1, field_2)
        expect(Field.favourite_by_current_user user.favourite_field_ids)
        .not_to include(field_3)
      end
    end

    context "when falsy or no argument provied" do
      it "returns empty" do
        expect(Field.favourite_by_current_user).to be_empty
        expect(Field.favourite_by_current_user nil).to be_empty
      end
    end
  end

  describe "#average_rating" do
    let!(:field_1){create :field}
    let!(:field_2){create :field}
    let!(:field_3){create :field}

    let!(:rating_1){create :rating, field: field_1, rating: 1.0}
    let!(:rating_2){create :rating, field: field_1, rating: 3.0}
    let!(:rating_3){create :rating, field: field_2, rating: 4.0}
    let!(:rating_4){create :rating, field: field_2, rating: 3.0}
    let!(:rating_5){create :rating, field: field_2, rating: 3.0}

    it "returns average rating round to first decimal point" do
      expect(field_1.average_rating).to eq(2.0)
      expect(field_2.average_rating).to eq(3.3)
    end

    it "returns zero if have no rating yet" do
      expect(field_3.average_rating).to be_zero
    end
  end

  describe "#has_any_uncompleted_order?" do
    let(:field_1){create :field}
    let(:field_2){create :field}
    let(:field_3){create :field}
    let!(:order_1){create :order_field, field: field_1}
    let!(:order_2){create :order_field, field: field_1, status: :pending}

    context "when any uncompleted order with approved status exists" do
      it "returns true" do
        expect(field_1.has_any_uncompleted_order?).to be_truthy
      end
    end

    context "when no order or order with another status exists" do
      it "returns false" do
        expect(field_2.has_any_uncompleted_order?).to be_falsy
        expect(field_3.has_any_uncompleted_order?).to be_falsy
      end
    end
  end
end
