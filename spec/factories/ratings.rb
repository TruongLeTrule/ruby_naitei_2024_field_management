FactoryBot.define do
  factory :rating do
    user
    description{Faker::Lorem.sentence(word_count: 10)}
  end
end
