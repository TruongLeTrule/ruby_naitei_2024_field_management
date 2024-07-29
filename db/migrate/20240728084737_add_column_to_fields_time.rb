class AddColumnToFieldsTime < ActiveRecord::Migration[7.0]
  def change
    add_column :fields, :open_time, :time
    add_column :fields, :close_time, :time
  end
end
