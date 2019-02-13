# frozen_string_literal: true

namespace :consents do
  desc "Initialize consents in database"
  # Update existing cosnet
  task initialize: :environment do
    Consent.where(version: "1").first_or_create.update(start_date: "2017-09-11", end_date: "2018-02-07")
    Consent.where(version: "2").first_or_create.update(start_date: "2018-02-08", end_date: "2018-02-20")
    Consent.where(version: "3").first_or_create.update(start_date: "2018-02-21", end_date: "2018-04-11")
    Consent.where(version: "4").first_or_create.update(start_date: "2018-04-12", end_date: "2018-11-08")
    Consent.where(version: "5").first_or_create.update(start_date: "2018-11-09", end_date: nil)
  end

  desc "Export consents in PDF format."
  task export: :environment do
    users = User.consented
    total_count = users.count
    string_length = total_count.to_s.size
    count = 1

    consent_original_folder = Rails.root.join("carrierwave", "consents", "original")
    consent_latest_folder = Rails.root.join("carrierwave", "consents", "latest")

    reset_export_folder(consent_original_folder)
    reset_export_folder(consent_latest_folder)

    latest_consent = Consent.find_latest

    users.find_each do |user|
      original_consent = user.original_consent
      next unless latest_consent && original_consent

      initials = user.initials.downcase

      original_pdf_name = generate_consent_pdf_name(original_consent.version, initials)
      latest_pdf_name = generate_consent_pdf_name(latest_consent.version, initials)

      user.generate_consent_pdf!(:original)
      user.generate_consent_pdf!(:latest)

      progress = "[#{format("%#{string_length}d", count)} of #{total_count} (#{count * 100 / total_count}%)]"
      print "\r#{progress} #{original_pdf_name}      "

      if File.exist?(user.consent_original_pdf.path.to_s)
        FileUtils.cp user.consent_original_pdf.path, File.join(consent_original_folder, original_pdf_name)
      end

      if File.exist?(user.consent_latest_pdf.path.to_s)
        FileUtils.cp user.consent_latest_pdf.path, File.join(consent_latest_folder, latest_pdf_name)
      end

      count += 1
    end
    puts ""
  end
end

def reset_export_folder(folder)
  FileUtils.mkdir_p folder
  FileUtils.rm Dir.glob(File.join(folder, "*.pdf"))
end

def generate_consent_pdf_name(version, initials)
  "consent-v#{version}-#{initials}-#{SecureRandom.hex(4)}.pdf"
end
