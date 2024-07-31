class AddIndexToFieldsName < ActiveRecord::Migration[7.0]
  def change
    add_index :fields, :name
  end
end
