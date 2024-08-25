FactoryBot.define do
  factory :order_field do
    user
    field
    final_price{rand 100_000...500_000}
    started_time{"16:00"}
    finished_time{"17:00"}
    date{Time.zone.tomorrow}
    status{:approved}
  end
end
