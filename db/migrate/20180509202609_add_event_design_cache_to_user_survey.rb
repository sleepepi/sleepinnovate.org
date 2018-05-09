class AddEventDesignCacheToUserSurvey < ActiveRecord::Migration[5.2]
  def change
    add_column :user_surveys, :design_name_cache, :string
    add_column :user_surveys, :design_slug_cache, :string
    add_column :user_surveys, :event_slug_cache, :string
  end
end
