class AddTesterToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :tester, :boolean, null: false, default: false
    add_index :users, :tester
  end
end
