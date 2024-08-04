module RatingsHelper
  def find_rating field
    current_user.ratings.find_by field_id: field.id
  end
end
