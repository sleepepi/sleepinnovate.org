class ChangeOtherKeysToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :slice_subject_id, :bigint
    change_column :users, :date_of_birth_encrypted_field_id, :bigint
    change_column :users, :address_encrypted_field_id, :bigint
  end

  def down
    change_column :users, :slice_subject_id, :integer
    change_column :users, :date_of_birth_encrypted_field_id, :integer
    change_column :users, :address_encrypted_field_id, :integer
  end
end
