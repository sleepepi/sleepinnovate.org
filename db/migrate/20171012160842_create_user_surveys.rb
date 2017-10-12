class CreateUserSurveys < ActiveRecord::Migration[5.1]
  def change
    create_table :user_surveys do |t|
      t.integer :user_id
      t.string :event
      t.string :design
      t.boolean :completed, null: false, default: false
      t.index :user_id
      t.timestamps
    end
  end
end
