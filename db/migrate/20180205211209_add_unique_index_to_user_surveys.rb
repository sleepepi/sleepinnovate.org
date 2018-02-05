class AddUniqueIndexToUserSurveys < ActiveRecord::Migration[5.2]
  def change
    add_index :user_surveys, [:user_id, :event, :design], unique: true, name: "index_user_slice_surveys"
  end
end
