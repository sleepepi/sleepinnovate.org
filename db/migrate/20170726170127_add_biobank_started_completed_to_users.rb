class AddBiobankStartedCompletedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :biobank_started, :datetime
    add_column :users, :biobank_completed, :datetime
  end
end
