class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :name
      t.string :slug
      t.integer :month, null: false, default: 0
      t.string :time_ago
      t.timestamps
    end
  end
end
