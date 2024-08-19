class CreateNewActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :new_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :action
      t.string :name
      t.references :trackable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
