class ActivitiesController < ApplicationController
  def index
    @pagy, @activities = pagy PublicActivity::Activity
                         .where(owner: current_user)
                         .order(created_at: :desc)
                         .includes(:owner, :trackable)
  end
end
