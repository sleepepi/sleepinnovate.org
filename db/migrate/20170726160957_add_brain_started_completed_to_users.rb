class AddBrainStartedCompletedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :brain_started, :datetime
    add_column :users, :brain_completed, :datetime
  end
end
