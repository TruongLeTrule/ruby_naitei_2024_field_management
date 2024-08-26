FactoryBot.define do
  factory :user do
    email{Faker::Internet.email}
    name{Faker::Name.name}
    password{"*Password123"}
    confirmed_at {Time.zone.now}
  end
end
