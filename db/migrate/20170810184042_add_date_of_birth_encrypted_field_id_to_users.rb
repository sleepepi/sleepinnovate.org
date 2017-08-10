class AddDateOfBirthEncryptedFieldIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :date_of_birth_encrypted_field_id, :integer
    add_index :users, :date_of_birth_encrypted_field_id
  end
end
