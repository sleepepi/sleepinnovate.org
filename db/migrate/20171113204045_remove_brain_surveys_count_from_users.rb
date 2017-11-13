class RemoveBrainSurveysCountFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :brain_surveys_count, :integer, null: false, default: 0
  end
end
