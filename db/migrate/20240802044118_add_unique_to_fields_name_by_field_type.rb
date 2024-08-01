class AddUniqueToFieldsNameByFieldType < ActiveRecord::Migration[7.0]
  def change
    add_index :fields, [:field_type_id, :name], unique: true
  end
end
