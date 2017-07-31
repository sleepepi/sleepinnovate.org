class AddBrainStartedCompletedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :brain_started_at, :datetime
    add_column :users, :brain_completed_at, :datetime
  end
end
