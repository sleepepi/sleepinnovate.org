class AddSliceSubjectIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :slice_subject_id, :integer
    add_index :users, :slice_subject_id, unique: true
  end
end
