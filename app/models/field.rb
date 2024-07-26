class Field < ApplicationRecord
  belongs_to :field_type
  has_many :unavailable_field_schedules, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
  dependent: :destroy
  has_many :favourite_users, through: :favourite_relationships,
source: :user
  has_many :order_relationships, class_name: OrderField.name,
    dependent: :destroy
  has_many :ordered_users, through: :order_relationships,
source: :user
  has_many :ratings, dependent: :destroy

  scope :name_like, ->(name){where("name LIKE ?", "%#{name}%") if name.present?}
  scope :order_by, lambda {|attribute, direction = :asc|
                     order(attribute => direction)
                   }

  def average_rating
    ratings.average(:rating).to_f
  end
end
