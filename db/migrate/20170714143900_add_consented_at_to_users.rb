class AddConsentedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :consented_at, :datetime
  end
end
