class ChangeEventIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :user_events, :event_id, :bigint
  end

  def down
    change_column :user_events, :event_id, :integer
  end
end
