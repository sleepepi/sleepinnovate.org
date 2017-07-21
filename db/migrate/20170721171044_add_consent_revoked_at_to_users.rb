class AddConsentRevokedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :consent_revoked_at, :datetime
  end
end
