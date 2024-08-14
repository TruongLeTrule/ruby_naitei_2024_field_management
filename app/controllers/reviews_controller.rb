class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_rating, only: %i(new create)
  before_action :load_review, only: %i(edit update destroy)

  def new
    @review = @rating.reviews.build
  end

  def create
    @review = @rating.reviews.build(user_id: current_user.id, **review_params)

    return unless @review.save

    turbo_stream
  end

  def edit; end

  def update
    return unless @review.update review_params

    turbo_stream
  end

  def destroy
    return unless @review.destroy

    turbo_stream
  end

  private

  def review_params
    params.require(:review).permit Review::CREATE_ATTRIBUTES
  end

  def load_review
    return if @review = Review.find_by(id: params[:id])

    flash[:danger] = t "reviews.errors.invalid_review"
    redirect_to root_path, status: :unprocessable_entity
  end
end
