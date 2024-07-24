class Field < ApplicationRecord
  belongs_to :field_type
  has_many :unavailable_field_schedules, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
  dependent: :destroy
  has_many :favourite_users, through: :favourite_relationships,
source: :user
  has_many :order_relationships, class_name: OrderField.name,
    dependent: :destroy
  has_many :order_users, through: :order_relationships,
source: :user
  has_many :ratings, dependent: :destroy
end
