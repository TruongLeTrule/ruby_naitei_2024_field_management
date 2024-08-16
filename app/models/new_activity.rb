class NewActivity < ApplicationRecord
  enum action: {created: 0, viewed: 1, updated: 2, deleted: 3}

  belongs_to :user
  belongs_to :trackable, polymorphic: true, optional: true

  scope :by_user, ->(user){where(user:)}
end
