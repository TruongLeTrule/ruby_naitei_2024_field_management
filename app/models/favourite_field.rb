class FavouriteField < ApplicationRecord
  belongs_to :user
  belongs_to :field
  has_many :activities, as: :trackable, dependent: :nullify

  after_create :create_activity

  private

  def create_activity
    create_action(user, :created, self)
  end
end
