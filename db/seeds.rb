# User
puts "Seeding users..."

admin = User.new name: "admin",
                     email: "admin@gmail.com",
                     money: 1000000,
                     password: "*Password123",
                     admin: true
admin.skip_confirmation!
admin.save!
30.times do |i|
  name = Faker::Name.name
  email = Faker::Internet.email
  money = rand 100_000..1000_000
  password = "*Password123"
  activated = true
  activated_at = Time.zone.now
  user = User.new name: name,
                  email: email,
                  money: money,
                  password: password
  user.skip_confirmation!
  user.save!
end

# Field Type
puts "Seeding fields..."

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
  name = Faker::Sports::Football.unique.team
  default_price = rand 100_000..500_000
  description = Faker::Lorem.sentence(word_count: 50)
  open_time = "08:00am"
  close_time = "09:00pm"
  field_type_id = field_type.id
  field_type.fields.create! name: name,
                            default_price: default_price,
                            description:description,
                            field_type_id:field_type_id,
                            open_time: open_time,
                            close_time: close_time
end

# Rating + Favourite + Order
puts "Seeding rating + favourite + order..."

$order_id = 0
fields = Field.limit 4
fields.each do |field|
  30.times do |id|
    field.ratings.create! user_id: id + 1,
                          rating: rand(1..5),
                          description: Faker::Lorem.sentence(word_count: 20)

    field.favourite_relationships.create! user_id: id + 1

    field.order_relationships.create! user_id: id + 1,
                                      started_time: "16:00",
                                      finished_time: "17:00",
                                      date: Time.zone.today + (id + 1).days,
                                      final_price: rand(100_000..500_000),
                                      status: 1

    field.unavailable_field_schedules.create! started_time: "16:00",
                                              finished_time: "17:00",
                                              started_date: Time.zone.today + (id + 1).days,
                                              finished_date: Time.zone.today + (id + 1).days,
                                              status: 2,
                                              order_field_id: $order_id + 1
    $order_id = $order_id + 1
  end
end

# Voucher
puts "Seeding vouchers..."

users = User.limit 5
users.each do |user|
  5.times do |i|
    type = i % 2
    if type == 0
      user.vouchers.create! voucher_type: type, amount: 0.5
    else
      user.vouchers.create! voucher_type: type, amount: 100_000
    end
  end
end
