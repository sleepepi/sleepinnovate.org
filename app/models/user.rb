# frozen_string_literal: true

# Defines a user in the web application.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :omniauthable
  devise :database_authenticatable, :lockable, :registerable, :recoverable,
         :rememberable, :timeoutable, :trackable, :validatable

  # Concerns
  include Deletable
  include Forkable
  include Latexable

  # Constants
  BIOBANK_STATUS = [
    ["Unconsented", "unconsented"],
    ["Consented", "consented"],
    ["Opted Out", "opted_out"]
  ]

  # Validations
  validates :full_name, presence: true

  # Uploaders
  mount_uploader :consent_signature, SignatureUploader

  # Delegations
  delegate :subject_events, to: :subject
  delegate :subject_code, to: :subject
  delegate :launch_survey!, to: :subject
  delegate :next_survey, to: :subject
  delegate :survey_path, to: :subject
  delegate :baseline_surveys_completed?, to: :subject

  # Methods

  def name
    if admin?
      full_name
    elsif consented?
      subject_code
    end
  end

  def consent!(data_uri)
    save_signature!(data_uri)
    update(consented_at: Time.zone.now, consent_revoked_at: nil)
  end

  def revoke_consent!
    update(consent_revoked_at: Time.zone.now)
  end

  # Only to be used by admins in case user accidentally revoked consent.
  def unrevoke_consent!
    update(consent_revoked_at: nil)
  end

  def test_my_brain_started!
    return unless brain_started.nil?
    update(brain_started: Time.zone.now)
  end

  def test_my_brain_completed!
    return unless brain_completed.nil?
    update(brain_completed: Time.zone.now)
  end

  def biobank_registration_started!
    return unless biobank_started.nil?
    update(biobank_started: Time.zone.now)
  end

  def biobank_registration_completed!
    return unless biobank_completed.nil?
    update(biobank_completed: Time.zone.now)
  end

  def consented?
    !consented_at.nil? && consent_revoked_at.nil?
  end

  def consent_revoked?
    !consent_revoked_at.nil?
  end

  def unconsented?
    consented_at.nil? && consent_revoked_at.nil?
  end

  def awards_count
    0
  end

  def slice_surveys_step?
    consented?
  end

  def brain_surveys_step?
    baseline_surveys_completed?
  end

  def brain_surveys_started?
    !brain_started.nil?
  end

  def brain_surveys_completed?
    !brain_completed.nil?
  end

  def biobank_registration_step?
    brain_surveys_completed?
  end

  def biobank_registration_started?
    !biobank_started.nil?
  end

  def biobank_registration_completed?
    !biobank_completed.nil?
  end

  def biobank_opted_out?
    false
  end

  def biobank_status_string
    BIOBANK_STATUS.find { |_name, value| value == biobank_status }.first
  end

  def whats_next?
    baseline_surveys_completed? && brain_surveys_completed? && (biobank_registration_completed? || biobank_opted_out?)
  end

  def subject
    @subject ||= Subject.new(self)
  end

  def save_signature!(data_uri)
    file = Tempfile.new("consent_signature.png")
    begin
      encoded_image = data_uri.split(",")[1]
      decoded_image = Base64.decode64(encoded_image)
      File.open(file, "wb") { |f| f.write(decoded_image) }
      file.define_singleton_method(:original_filename) do
        "consent_signature.png"
      end
      self.consent_signature = file
      save
    ensure
      file.close
      file.unlink # deletes the temp file
    end
  end

  def send_welcome_email_in_background(token)
    fork_process(:send_welcome_email, token)
  end

  def send_welcome_email(token)
    RegistrationMailer.welcome_email(self, token).deliver_now if EMAILS_ENABLED
  end

  def self.latex_partial(partial)
    File.read(File.join("app", "views", "latex", "_#{partial}.tex.erb"))
  end

  def self.generate_printed_pdf!(current_user)
    jobname = current_user ? "consent_#{current_user.id}" : "consent"
    output_folder = File.join("tmp", "files", "tex")
    FileUtils.mkdir_p output_folder
    file_tex = File.join("tmp", "files", "tex", "#{jobname}.tex")
    @user = current_user # Needed by Binding
    File.open(file_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("header")).result(binding))
      file.syswrite(ERB.new(latex_partial("consent")).result(binding))
      file.syswrite(ERB.new(latex_partial("footer")).result(binding))
    end
    generate_pdf(jobname, output_folder, file_tex)
  end
end
