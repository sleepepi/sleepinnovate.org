class AddPdfFileToConsents < ActiveRecord::Migration[6.0]
  def change
    add_column :consents, :pdf_file, :string
    add_column :consents, :pdf_file_size, :bigint, null: false, default: 0
    add_column :consents, :pdf_file_created_at, :datetime
  end
end
