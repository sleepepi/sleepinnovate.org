class AddBiobankStatusToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :biobank_status, :string, null: false, default: "unconsented"
    add_index :users, :biobank_status
  end
end
