class CreateUserEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :user_events do |t|
      t.integer :user_id
      t.integer :event_id
      t.datetime :activation_email_sent_at
      t.datetime :reminder_email_sent_at
      t.index [:user_id, :event_id], unique: true
      t.timestamps
    end
  end
end
