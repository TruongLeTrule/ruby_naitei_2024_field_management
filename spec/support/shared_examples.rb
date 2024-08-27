RSpec.shared_examples "an invalid field" do
  it "sets a danger flash" do
    expect(flash[:danger]).to eq(I18n.t("fields.errors.invalid"))
  end

  it "redirect to root path" do
    expect(response).to redirect_to(root_path)
    expect(response).to have_http_status(:redirect)
  end
end

RSpec.shared_examples "require login action" do
  it "sets a danger flash" do
    expect(flash[:danger]).to eq(I18n.t("users.errors.require_login"))
  end

  it "redirect to root path" do
    expect(response).to redirect_to(new_user_session_path)
    expect(response).to have_http_status(:redirect)
  end
end
