require "rails_helper"

RSpec.describe FieldsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:default_locale){:vi}
  let(:user){create :user}
  let(:field_1){create :field}
  let(:field_2){create :field}
  let!(:rating_1){create :rating, field: field_1, rating: 4.0}
  let!(:rating_2){create :rating, field: field_2, rating: 5.0}
  let!(:rating_3){create :rating, field: field_1, rating: 5.0}

  describe "ensuring locale always exists" do
    it "merges default locale to request path" do
      get :index
      expect(response).to redirect_to(root_path(locale: :vi))
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #index" do
    context "when query params is empty" do
      it "merges default params" do
        get :index, params: {locale: default_locale}
        expect(response).to redirect_to(fields_path(type: :all, most_rated: true))
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when query params is existed" do
      before{get :index, params: {locale: default_locale, type: :all, most_rated: true}}

      it "renders index template" do
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end

      it "assigns @fields" do
        expect(assigns(:fields)).to match_array([field_2, field_1])
      end
    end
  end

  describe "GET #show" do
    context "when field id is invalid" do
      before{get :show, params: {locale: default_locale, id: "nonexistent_id"}}

      it_behaves_like "an invalid field"
    end

    context "when field id is valid" do
      before{get :show, params: {locale: default_locale, id: field_1.id}}

      it "renders show template" do
        expect(response).to render_template(:show)
        expect(response).to have_http_status(:ok)
      end

      it "assigns @field according to request params" do
        expect(assigns(:field)).to eq(Field.find_by id: request.params[:id])
      end

      it "assigns @ratings in latest order" do
        expect(assigns(:ratings)).to match_array([rating_3, rating_1])
      end
    end


  end

  describe "GET #new_order" do
    context "when field id is invalid" do
      before{get :new_order, params: {locale: default_locale, id: "nonexistent_id"}}

      it_behaves_like "an invalid field"
    end

    context "when field id is valid" do
      context "if user has not logged in" do
        before{get :new_order, params: {locale: default_locale, id: field_1.id}}

        it_behaves_like "require login action"
      end

      context "if user logged in" do
        before do
          sign_in user
          get :new_order, params: {locale: default_locale, id: field_1.id}
        end

        it "renders new_order template" do
          expect(response).to render_template(:new_order)
          expect(response).to have_http_status(:ok)
        end

        it "assigns @field according to request params" do
          expect(assigns(:field)).to eq(Field.find_by id: request.params[:id])
        end

        it "assigns @order to new order" do
          expect(assigns(:order)).to be_a_new(OrderField)
        end
      end
    end
  end

  describe "POST #create_order" do
    context "when field id is invalid" do
      before{post :create_order, params: {locale: default_locale, id: "nonexistent_id"}}

      it_behaves_like "an invalid field"
    end

    context "when field id is valid" do
      context "if user has not logged in" do
        before{post :create_order, params: {locale: default_locale, id: field_1.id}}

        it_behaves_like "require login action"
      end

      context "if user logged in" do
        before{sign_in user}

        let(:valid_attributes){{
          user: user,
          field: field_1,
          started_time: "16:00",
          finished_time: "17:00",
          date: Time.zone.tomorrow
        }}
        let(:invalid_attributes){{user_id: -1}}

        context "if order attributes are valid" do
          before do
            post :create_order, params: {locale: default_locale, id: field_1.id, order_field: valid_attributes}
          end

          it "saves order successful" do
            expect(assigns(:order)).to be_persisted
          end

          it "saves unavailable schedule successful" do
            expect(assigns(:schedule)).to be_persisted
          end

          it "sets a succes flash" do
            expect(flash[:success]).to eq(I18n.t("fields.create_order.success"))
          end

          it "redirect to payment path" do
            expect(response).to redirect_to(edit_order_path(assigns(:order)))
            expect(response).to have_http_status(:redirect)
          end
        end

        context "if order attributes are invalid" do
          before do
            post :create_order, params: {locale: default_locale, id: field_1.id, order_field: invalid_attributes}
          end

          it "sets a danger flash" do
            expect(flash.now[:danger]).to be_present
          end

          it "returns a 422 unprocessable entity" do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
