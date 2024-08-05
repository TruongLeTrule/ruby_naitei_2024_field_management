class Review < ApplicationRecord
  CREATE_ATTRIBUTES = %i(description).freeze

  belongs_to :user
  belongs_to :parent_rating, class_name: Rating.name, optional: true
  belongs_to :parent_review, class_name: Review.name, optional: true
  has_many :children_reviews, class_name: Review.name,
foreign_key: :parent_review_id, dependent: :destroy
  has_many :activities, as: :trackable, dependent: nil

  validates :description, presence: true

  after_create :create_activity
  after_update :update_activity
  before_destroy :destroy_activity

  private

  def create_activity
    create_action(user, :created, self)
  end

  def update_activity
    create_action(user, :updated, self)
  end

  def destroy_activity
    create_action(user, :deleted, self)
  end
end
