class CreateConsents < ActiveRecord::Migration[6.0]
  def change
    create_table :consents do |t|
      t.integer :version
      t.date :start_date
      t.date :end_date
      t.timestamps
      t.index :version
    end
  end
end
