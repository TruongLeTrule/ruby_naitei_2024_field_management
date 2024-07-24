class Review < ApplicationRecord
  belongs_to :user
  belongs_to :parent_rating, class_name: Rating.name, optional: true
  belongs_to :parent_review, class_name: Review.name, optional: true
  has_many :children_reviews, class_name: Review.name,
foreign_key: :parent_review_id, dependent: :destroy
end
