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
    default_price = rand(100.000..500.000)
    description = Faker::Lorem.sentence(word_count: 10)
    field_type_id = field_type.id
    field_type.fields.create! name: name,
                              default_price: default_price,
                              description:description,
                              field_type_id:field_type_id
  end
end
