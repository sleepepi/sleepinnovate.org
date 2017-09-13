class CreateBrainTests < ActiveRecord::Migration[5.1]
  def change
    create_table :brain_tests do |t|
      t.integer :battery_number
      t.string :test_name
      t.integer :test_number
      t.text :test_outcomes
      t.integer :user_id
      t.index :user_id
      t.string :event
      t.timestamps
    end
  end
end
