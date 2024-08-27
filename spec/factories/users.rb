FactoryBot.define do
  factory :user do
    name {Faker::Name.name}
    email {Faker::Internet.email}
    money {rand 100_000..1000_000}
    password {"*Password123"}
    confirmed_at{Time.zone.now}
    trait :admin do
      admin {true}
    end
  end
end
