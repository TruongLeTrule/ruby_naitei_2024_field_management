class ActivitiesController < ApplicationController
  def index
    @pagy, @activities = pagy Activity.by_user(current_user)
                                      .order(created_at: :desc)
                                      .includes(:user, :trackable)
  end
end
