class CreateEncryptedFields < ActiveRecord::Migration[5.1]
  def change
    create_table :encrypted_fields do |t|
      t.string :encrypted_data
      t.string :encrypted_data_iv
      t.integer :data_encryption_key_id
      t.index :data_encryption_key_id
      t.timestamps
    end
  end
end
