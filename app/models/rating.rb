class Rating < ApplicationRecord
  include PublicActivity::Model
  tracked owner: :user

  PERMITTED_ATTRIBUTES = %i(rating description).freeze

  belongs_to :user
  belongs_to :field
  has_many :reviews, foreign_key: "parent_rating_id", dependent: :destroy

  validates :description, presence: true,
                          length: {maximum: Settings.max_length_255}

  scope :lastest, ->{order created_at: :desc}
end
