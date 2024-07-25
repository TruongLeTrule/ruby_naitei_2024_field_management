class FieldType < ApplicationRecord
  enum ground: {grass: 0, artificial_grass: 1, indoor: 2,
                concrete: 3}

  has_many :fields, dependent: :destroy
end
