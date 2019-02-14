# frozen_string_literal: true

# Tracks different consents over time.
class Consent < ApplicationRecord
  # Uploaders
  mount_uploader :pdf_file, PDFUploader

  # Concerns
  include Latexable

  # Methods
  def self.find_latest
    find_by end_date: nil
  end

  def cached_or_generate_pdf!
    # Don't regenerate PDF if it's already been created.
    return if pdf_file_created_at && pdf_file_created_at > updated_at

    generate_pdf!
  end

  def generate_pdf!
    jobname = "consent"
    temp_dir = Dir.mktmpdir
    temp_tex = File.join(temp_dir, "#{jobname}.tex")
    write_tex_file(temp_tex)
    self.class.compile(jobname, temp_dir, temp_tex)
    temp_pdf = File.join(temp_dir, "#{jobname}.pdf")
    if File.exist?(temp_pdf)
      update(
        pdf_file: File.open(temp_pdf, "r"),
        pdf_file_size: File.size(temp_pdf)
      )
      # Don't
      update_column :pdf_file_created_at, Time.zone.now
    end
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def write_tex_file(temp_tex, user: nil)
    # Required by binding
    @user = user
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(consent_partial("header", version_folder: "v#{version}")).result(binding))
      file.syswrite(ERB.new(consent_partial("consent", version_folder: "v#{version}")).result(binding))
      file.syswrite(ERB.new(consent_partial("signature")).result(binding))
      file.syswrite(ERB.new(consent_partial("footer")).result(binding))
    end
  end

  def consent_partial(partial, version_folder: nil)
    if version_folder
      File.read(File.join("app", "views", "consents", version_folder, "_#{partial}.tex.erb"))
    else
      File.read(File.join("app", "views", "consents", "_#{partial}.tex.erb"))
    end
  end
end
