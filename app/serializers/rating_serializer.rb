class RatingSerializer < ActiveModel::Serializer
  belongs_to :user, serializer: UserSerializer
  has_many :reviews, serializer: ReviewSerializer

  attributes %i(id description rating updated_at created_at)
end
