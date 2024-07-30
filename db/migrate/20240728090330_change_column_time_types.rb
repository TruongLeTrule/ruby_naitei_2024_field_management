class ChangeColumnTimeTypes < ActiveRecord::Migration[7.0]
  def change
    change_column :order_fields, :started_time, :time
    change_column :order_fields, :finished_time, :time
    change_column :unavailable_field_schedules, :started_time, :time
    change_column :unavailable_field_schedules, :finished_time, :time
  end
end
