class FavouritesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_field_by_id, only: :create
  before_action :load_favourite, only: :destroy

  def create
    current_user.add_favourite_field(@field)
    respond_to do |format|
      format.html{redirect_to @field}
      format.turbo_stream
    end
  end

  def destroy
    @field = @favourite.field
    create_action(current_user, :deleted, @favourite)
    current_user.remove_favourite_field(@field)
    respond_to do |format|
      format.html{redirect_to @field}
      format.turbo_stream
    end
  end

  private

  def load_favourite
    @favourite = FavouriteField.find_by id: params[:id]
    return if @favourite

    flash[:danger] = t "favourites.errors.invalid"
    redirect_to root_url
  end
end
