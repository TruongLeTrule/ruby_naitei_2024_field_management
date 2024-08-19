class ActivitiesController < ApplicationController
  load_and_authorize_resource class: "PublicActivity::Activity"
  def index
    @pagy, @activities = pagy @activities
                         .order(created_at: :desc)
                         .includes(:owner, :trackable)
  end
end
