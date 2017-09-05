class RemoveConsentSignatureFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :consent_signature, :text
  end
end
