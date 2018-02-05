class AddUniqueIndexToBrainTests < ActiveRecord::Migration[5.2]
  def change
    add_index :brain_tests, [:user_id, :event, :battery_number, :test_number], unique: true, name: "index_user_brain_tests"
  end
end
