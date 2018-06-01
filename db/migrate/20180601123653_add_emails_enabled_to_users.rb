class AddEmailsEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :emails_enabled, :boolean, null: false, default: true
    add_index :users, :emails_enabled
  end
end
