class FavouriteField < ApplicationRecord
  include PublicActivity::Model
  tracked owner: :user

  belongs_to :user
  belongs_to :field
end
