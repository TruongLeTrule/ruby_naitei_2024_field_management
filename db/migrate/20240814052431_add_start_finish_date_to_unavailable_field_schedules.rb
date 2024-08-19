class AddStartFinishDateToUnavailableFieldSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :unavailable_field_schedules, :started_date, :date
    add_column :unavailable_field_schedules, :finished_date, :date
    remove_column :unavailable_field_schedules, :date, :date
  end
end
