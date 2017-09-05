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
  include Encrypted

  # Encrypted Fields
  encrypted :address
  encrypted :date_of_birth

  # Constants
  BIOBANK_STATUS = [
    ["Unconsented", "unconsented"],
    ["Consented", "consented"],
    ["Opted Out", "opted_out"]
  ]

  TEST_MY_BRAIN_SURVEYS = [
    ["Matching Shapes and Numbers", 1],
    ["Placeholder", 2]
  ]

  # Validations
  validates :full_name, presence: true
  validates :password, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./,
    message: "must include at least one lowercase letter, one uppercase letter, and one digit"
  }, allow_blank: true

  # Uploaders
  mount_uploader :consent_signature, SignatureUploader

  # Delegations
  delegate :subject_events, to: :subject
  delegate :subject_code, to: :subject
  delegate :launch_survey!, to: :subject
  delegate :next_survey, to: :subject
  delegate :baseline_surveys_completed?, to: :subject
  delegate :total_baseline_surveys_count, to: :subject
  delegate :baseline_surveys_completed_count, to: :subject
  delegate :start_event_survey, to: :subject
  delegate :resume_event_survey, to: :subject
  delegate :page_event_survey, to: :subject
  delegate :submit_response_event_survey, to: :subject
  delegate :complete_event_survey, to: :subject
  delegate :current_event, to: :subject

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
    send_consent_pdf_email_in_background
  end

  def revoke_consent!
    update(consent_revoked_at: Time.zone.now)
  end

  # Only to be used by admins in case user accidentally revoked consent.
  def unrevoke_consent!
    update(consent_revoked_at: nil)
  end

  # Only used by admins when Slice failed to initially set a subject code.
  def assign_subject!
    return if subject_code.present?
    update(slice_subject_id: nil)
  end

  def test_my_brain_started!
    return unless brain_started_at.nil?
    update(brain_started_at: Time.zone.now)
  end

  def test_my_brain_completed!
    return unless brain_completed_at.nil?
    update(brain_completed_at: Time.zone.now)
  end

  def brain_baseline_surveys_completed
    brain_surveys_count
  end

  def brain_baseline_surveys_count
    TEST_MY_BRAIN_SURVEYS.size
  end

  def brain_baseline_percent
    return 100 if brain_baseline_surveys_count.zero?
    brain_baseline_surveys_completed * 100 / brain_baseline_surveys_count
  end

  def biobank_registration_started!
    return unless biobank_started_at.nil?
    update(biobank_started_at: Time.zone.now)
  end

  def biobank_registration_completed!
    return unless biobank_completed_at.nil?
    update(biobank_completed_at: Time.zone.now)
  end

  def consented?
    !consented_at.nil? && consent_revoked_at.nil?
  end

  def refused?
    consented_at.nil? && !consent_revoked_at.nil?
  end

  def withdrawn?
    !consented_at.nil? && !consent_revoked_at.nil?
  end

  # Equivalent to (refused? || withdrawn?)
  def consent_revoked?
    !consent_revoked_at.nil?
  end

  def unconsented?
    consented_at.nil? && consent_revoked_at.nil?
  end

  def awards_count
    if baseline_surveys_completed?
      1
    else
      0
    end
  end

  def slice_surveys_step?
    consented?
  end

  def brain_surveys_viewable?
    !first_login? && profile_complete?
  end

  def brain_surveys_started?
    !brain_started_at.nil?
  end

  def brain_surveys_completed?
    !brain_completed_at.nil?
  end

  def biobank_viewable?
    !first_login? && profile_complete?
  end

  def biobank_registration_step?
    brain_surveys_completed?
  end

  def biobank_registration_started?
    !biobank_started_at.nil?
  end

  def biobank_registration_completed?
    !biobank_completed_at.nil?
  end

  def biobank_opted_out?
    false
  end

  def biobank_status_string
    BIOBANK_STATUS.find { |_name, value| value == biobank_status }.first
  end

  def first_login?
    sign_in_count == 1
  end

  def parking_voucher?
    first_login? && profile_complete?
  end

  def profile_complete?
    consented? && dob.present? && address.present?
  end

  def whats_next?
    baseline_surveys_completed? && brain_surveys_completed? && (biobank_registration_completed? || biobank_opted_out?)
  end

  def subject
    @subject ||= Subject.new(self)
  end

  def dob
    Date.parse(date_of_birth)
  rescue
    nil
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

  def send_consent_pdf_email_in_background
    fork_process(:send_consent_pdf_email)
  end

  def send_consent_pdf_email
    ConsentMailer.consent_pdf_email(self).deliver_now if EMAILS_ENABLED
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

  def at_least_18?(date)
    date.in?(Date.parse("1900-01-01")..(Time.zone.today - 18.years))
  end

  def update_profile!(date, addr)
    return false if date.blank? || addr.blank?
    return false unless at_least_18?(date)
    update(date_of_birth: date, address: addr)
  end

  def update_address!(addr)
    return false if addr.blank?
    update(address: addr)
  end

  def update_date_of_birth!(date)
    return false if date.blank?
    return false unless at_least_18?(date)
    update(date_of_birth: date)
  end
end
