class AddConsentPdfFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :consent_latest_pdf, :string
    add_column :users, :consent_latest_pdf_file_size, :bigint, null: false, default: 0
    add_column :users, :consent_original_pdf, :string
    add_column :users, :consent_original_pdf_file_size, :bigint, null: false, default: 0
  end
end
