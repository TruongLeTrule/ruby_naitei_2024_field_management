class User < ApplicationRecord
  has_many :vouchers, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
                                    dependent: :destroy
  has_many :favourite_fields, through: :favourite_relationships,
source: :field
  has_many :order_relationships, class_name: OrderField.name,
                                      dependent: :destroy
  has_many :order_fields, through: :order_relationships,
source: :field
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
end
