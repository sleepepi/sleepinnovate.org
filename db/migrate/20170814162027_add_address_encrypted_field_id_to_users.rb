class AddAddressEncryptedFieldIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :address_encrypted_field_id, :integer
    add_index :users, :address_encrypted_field_id
  end
end
