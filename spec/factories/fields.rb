FactoryBot.define do
  factory :field do
    field_type
    sequence :name do |n|
      "Field ##{n}"
    end
    default_price{rand 100_000...500_000}
    open_time{"09:00"}
    close_time{"21:00"}
  end
end
