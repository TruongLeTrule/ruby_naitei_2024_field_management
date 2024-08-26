class FieldSerializer < ActiveModel::Serializer
  belongs_to :field_type, serializer: FieldTypeSerializer
  has_many :ratings, if: ->{instance_options[:include_ratings]}

  attributes %i(id name default_price open_time close_time average_rating
img_url)

  def average_rating
    object.ratings.average(:rating).to_f.round(1) || 0.0
  end

  def img_url
    object.image.url if object.image.attached?
  end
end
