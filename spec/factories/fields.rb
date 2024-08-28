FactoryBot.define do
  factory :field do
    sequence :name do |n|
      "Field #{n}"
    end
    default_price {rand 100_000..500_000}
    description  {Faker::Lorem.sentence(word_count: 50)}
    open_time  {"08:00am"}
    close_time {"09:00pm"}
    association :field_type
  end
end
