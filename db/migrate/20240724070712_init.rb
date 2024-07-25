class Init < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.float :money
      t.string :password_digest
      t.string :remember_digest
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.string :activation_digest
      t.boolean :activated
      t.datetime :activated_at
      t.boolean :admin

      t.timestamps
    end

    create_table :field_types do |t|
      t.string :name
      t.integer :capacity
      t.integer :ground

      t.timestamps
    end

    create_table :fields do |t|
      t.float :default_price
      t.string :name
      t.text :description
      t.references :field_type, null: false, foreign_key: true

      t.timestamps
    end

    create_table :unavailable_field_schedules do |t|
      t.datetime :started_time
      t.datetime :finished_time
      t.date :date
      t.integer :status
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end

    create_table :favourite_fields do |t|
      t.references :user, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end

    create_table :order_fields do |t|
      t.datetime :started_time
      t.datetime :finished_time
      t.date :date
      t.float :final_price
      t.integer :status
      t.references :user, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end

    create_table :ratings do |t|
      t.text :description
      t.integer :rating
      t.references :user, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end

    create_table :reviews do |t|
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.references :parent_review, foreign_key: {to_table: :reviews}
      t.references :parent_rating, foreign_key: {to_table: :ratings}

      t.timestamps
    end

    create_table :vouchers do |t|
      t.float :discount_price
      t.float :discount_percent
      t.integer :type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
