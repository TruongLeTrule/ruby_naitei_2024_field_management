class UserSerializer < ActiveModel::Serializer
  attributes %i(name avatar_url)

  def avatar_url
    object.image.url if object.image.attached?
  end
end
