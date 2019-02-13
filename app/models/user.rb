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
    { battery_name: "Matching Shapes and Numbers", battery_number: 536, test_numbers: [693] },
    # { battery_name: "Memorizing Numbers", battery_number: 538, test_numbers: [694] },
    { battery_name: "Connect the Dots", battery_number: 540, test_numbers: [696, 697] },
    { battery_name: "Word Knowledge", battery_number: 541, test_numbers: [698] }, # Will be removed.
    { battery_name: "Memorizing Words", battery_number: 542, test_numbers: [700, 701] },
    { battery_name: "Maintaining Concentration", battery_number: 543, test_numbers: [702] }
    # { battery_name: "Follow the Hidden Smileys", battery_number: 544, test_numbers: [703] }
  ]

  # Scopes
  scope :consented, -> { current.where.not(consented_at: nil).where(tester: false) }
  scope :consented_with_testers, -> { current.where.not(consented_at: nil).where(consent_revoked_at: nil) }

  # Validations
  validates :full_name, presence: true
  validates :full_name, format: { with: /\A.+\s.+\Z/, message: "must include first and last name" }
  validates :email, confirmation: true
  validates :password, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./,
    message: "must include at least one lowercase letter, one uppercase letter, and one digit"
  }, allow_blank: true
  validates :clinic, format: {
    with: /\A[a-z\d\-]*\Z/
  }, allow_blank: true

  # Uploaders
  mount_uploader :signature, SignatureUploader
  mount_uploader :consent_latest_pdf, PDFUploader
  mount_uploader :consent_original_pdf, PDFUploader
  mount_uploader :overview_report_pdf, PDFUploader

  # Relationships
  has_many :brain_tests
  has_many :user_events
  has_many :user_surveys

  # Delegations
  delegate :subject_events, to: :subject
  delegate :subject_code, to: :subject
  delegate :launch_survey!, to: :subject
  delegate :next_survey, to: :subject
  delegate :resume_event_survey, to: :subject
  delegate :page_event_survey, to: :subject
  delegate :submit_response_event_survey, to: :subject
  delegate :complete_event_survey, to: :subject
  delegate :current_event, to: :subject
  delegate :review_event_survey, to: :subject
  delegate :report_event_survey, to: :subject

  delegate :create_event!, to: :subject
  delegate :event_launched?, to: :subject
  delegate :event_surveys_completed, to: :subject
  delegate :event_surveys_total, to: :subject

  # Methods

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def current_event_brain_code
    if current_event
      current_event.slug.upcase.gsub("-", "dash")
    else
      "BASELINE"
    end
  end

  def consent!
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

  def event_completed?(event)
    subject.event_completed?(event) && brain_percent(event) == 100
  end

  def highlight_brain?
    return false unless current_event
    subject.event_completed?(current_event)
  end

  def highlight_biobank?
    return true unless current_event
    event_completed?(current_event)
  end

  def test_my_brain_started!
    return unless brain_started_at.nil?
    update(brain_started_at: Time.zone.now)
  end

  def brain_surveys_completed(event)
    return 0 unless event
    brain_tests.active_tests.where(event: event.slug).count
  end

  def brain_surveys_count(event)
    return 0 unless event
    TEST_MY_BRAIN_SURVEYS.collect { |h| h[:test_numbers] }.flatten.size
  end

  def brain_percent(event)
    return 100 if brain_surveys_count(event).zero?
    brain_surveys_completed(event) * 100 / brain_surveys_count(event)
  end

  def next_brain_test
    all_tests_taken = brain_tests.where(event: current_event.slug).pluck(:battery_number)
    remaining_tests = TEST_MY_BRAIN_SURVEYS.reject do |hash|
      hash[:battery_number].in?(all_tests_taken)
    end
    remaining_tests.first[:battery_name] if remaining_tests.first
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

  def status
    if consented?
      "consented"
    elsif withdrawn?
      "withdrawn"
    elsif refused?
      "refused"
    else
      "unconsented"
    end
  end

  def awards_count
    events_completed = 0
    Event.order(:month).each do |event|
      events_completed += 1 if event_completed?(event)
    end
    events_completed
  end

  def slice_surveys_step?
    consented?
  end

  def brain_surveys_viewable?
    # !first_login? && profile_complete?
    profile_complete?
  end

  def brain_surveys_started?
    !brain_started_at.nil?
  end

  def brain_surveys_completed?(event)
    brain_surveys_completed(event) == brain_surveys_count(event)
  end

  def biobank_viewable?
    # !first_login? && profile_complete?
    profile_complete?
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
    consented? && dob.present? && address.present? && signature.present?
  end

  def whats_next?
    next_survey.nil? && brain_surveys_completed?(current_event) && (biobank_registration_completed? || biobank_opted_out?)
  end

  def next_event_title
    Event.order(:month).each do |event|
      return event.name unless event_launched?(event)
    end
    nil
  end

  def subject
    @subject ||= Subject.new(self)
  end

  def dob
    Date.parse(date_of_birth)
  rescue
    nil
  end

  def initials
    full_name.split(/[^a-zA-Z]/).collect(&:first).join("")
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

  def save_signature!(data_uri)
    file = Tempfile.new("signature.png")
    begin
      encoded_image = data_uri.split(",")[1]
      decoded_image = Base64.decode64(encoded_image.to_s)
      File.open(file, "wb") { |f| f.write(decoded_image) }
      file.define_singleton_method(:original_filename) do
        "signature.png"
      end
      self.signature = file
      save
    ensure
      file.close
      file.unlink # deletes the temp file
    end
  end

  def original_consent
    consent = Consent.find_by("start_date <= ? and end_date >= ?", consented_at.to_date, consented_at.to_date) if consented_at.present?
    consent = Consent.find_latest unless consent
    consent
  end

  # Print Consent
  def consent_partial(partial, version: nil)
    if version
      File.read(File.join("app", "views", "consents", "v#{version}", "_#{partial}.tex.erb"))
    else
      File.read(File.join("app", "views", "consents", "_#{partial}.tex.erb"))
    end
  end

  def consent_signature_partial
    File.read(File.join("app", "views", "consents", "_signature.tex.erb"))
  end

  def generate_consent_pdf!(history)
    jobname = "consent"
    temp_dir = Dir.mktmpdir
    case history
    when :latest
      consent = Consent.find_latest
    when :original
      consent = original_consent
    end
    return unless consent

    temp_tex = File.join(temp_dir, "#{jobname}.tex")
    write_tex_file(temp_tex, consent.version.to_s)
    self.class.compile(jobname, temp_dir, temp_tex)
    temp_pdf = File.join(temp_dir, "#{jobname}.pdf")
    if File.exist?(temp_pdf)
      case history
      when :latest
        update consent_latest_pdf: File.open(temp_pdf, "r"), consent_latest_pdf_file_size: File.size(temp_pdf)
      when :original
        update consent_original_pdf: File.open(temp_pdf, "r"), consent_original_pdf_file_size: File.size(temp_pdf)
      end
    end
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def write_tex_file(temp_tex, version)
    # Needed by binding
    @user = self
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(consent_partial("header", version: version)).result(binding))
      file.syswrite(ERB.new(consent_partial("consent", version: version)).result(binding))
      file.syswrite(ERB.new(consent_partial("signature")).result(binding))
      file.syswrite(ERB.new(consent_partial("footer")).result(binding))
    end
  end
end
