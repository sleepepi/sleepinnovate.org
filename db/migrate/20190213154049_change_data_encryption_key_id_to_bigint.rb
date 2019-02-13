class ChangeDataEncryptionKeyIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :encrypted_fields, :data_encryption_key_id, :bigint
  end

  def down
    change_column :encrypted_fields, :data_encryption_key_id, :integer
  end
end
