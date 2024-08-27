class ReviewSerializer < ActiveModel::Serializer
  belongs_to :user, serializer: UserSerializer

  attributes %i(id description updated_at created_at)
end
