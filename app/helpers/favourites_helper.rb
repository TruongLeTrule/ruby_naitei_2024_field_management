module FavouritesHelper
  def favourite field
    current_user.favourite_relationships.find_by field_id: field.id
  end
end
