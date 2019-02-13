class AddOverviewReportToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :overview_report_pdf, :string
    add_column :users, :overview_report_pdf_file_size, :bigint, null: false, default: 0
  end
end
