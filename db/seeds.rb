# Field Type
4.times do |i|
  name = "Type ##{i}"
  capacity = case i
  when  0
    5
  when  1
    7
  else
    11
  end

  FieldType.create! name: name,
                    capacity: capacity,
                    ground: 0
end

# Field
field_types = FieldType.all
field_types.each do |field_type|
  10.times do
    name = Faker::Sports::Football.team
    default_price = rand 100_000..500_000
    description = Faker::Lorem.sentence(word_count: 10)
    field_type_id = field_type.id
    field_type.fields.create! name: name,
                              default_price: default_price,
                              description:description,
                              field_type_id:field_type_id
  end
end

# User
User.create! name: "admin",
             email: "admin@gmail.com",
             money: 1000000,
             password: "*Password123",
             activated: true,
             activated_at: Time.zone.now,
             admin: true
30.times do
  name = Faker::Name.name
  email = Faker::Internet.email
  money = rand 100_000..1000_000
  password = "*Password123"
  activated = true
  activated_at = Time.zone.now
  User.create! name: name,
               email: email,
               money: money,
               password: password,
               activated:  activated,
               activated_at: activated_at
end

# Rating + Favourite + Order
fields = Field.limit 5
fields.each do |field|
  10.times do |id|
    field.ratings.create! user_id: id + 1,
                          rating: rand(1..5),
                          description: Faker::Lorem.sentence(word_count: 20)

    field.favourite_relationships.create! user_id: id + 1

    field.order_relationships.create! user_id: id + 1,
                                      started_time: Time.zone.now + id.day,
                                      finished_time: Time.zone.now + id.day + 1.hour,
                                      date: Time.zone.today,
                                      final_price: rand(100_000..500_000),
                                      status: 1
  end
end
