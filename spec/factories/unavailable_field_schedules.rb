FactoryBot.define do
  factory :unavailable_field_schedule do
    association :order_field
    started_time {"16:00"}
    finished_time {"17:00"}
    started_date {Time.zone.today + 1.day}
    finished_date {Time.zone.today + 1.day}
    status {2}
  end
end
