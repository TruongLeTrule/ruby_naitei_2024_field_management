class Admin::AdminController < ApplicationController
  before_action :authorize_admin

  private

  def authorize_admin
    authorize! :manage, :all
  end
end
