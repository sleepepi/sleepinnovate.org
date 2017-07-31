class AddBiobankStartedCompletedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :biobank_started_at, :datetime
    add_column :users, :biobank_completed_at, :datetime
  end
end
