class FieldTypeSerializer < ActiveModel::Serializer
  attributes %i(id name ground capacity)
end
