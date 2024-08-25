FactoryBot.define do
  factory :field_type do
    sequence :name do |n|
      "Type #{n}"
    end
    ground{:grass}
    capacity{11}
  end
end
