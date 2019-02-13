class ChangeUserIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :brain_tests, :user_id, :bigint
    change_column :user_events, :user_id, :bigint
    change_column :user_surveys, :user_id, :bigint
  end

  def down
    change_column :brain_tests, :user_id, :integer
    change_column :user_events, :user_id, :integer
    change_column :user_surveys, :user_id, :integer
  end
end
