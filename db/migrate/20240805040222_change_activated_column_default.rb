class ChangeActivatedColumnDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :activated, from: nil, to: false
    change_column_default :users, :money, from: nil, to: 0
  end
end
