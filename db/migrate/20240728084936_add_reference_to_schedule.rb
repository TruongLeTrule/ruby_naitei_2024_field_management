class AddReferenceToSchedule < ActiveRecord::Migration[7.0]
  def change
    add_reference :unavailable_field_schedules, :order_field, foreign_key: true, null: true
  end
end
