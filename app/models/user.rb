# frozen_string_literal: true

# Defines a user in the web application.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Concerns
  include Deletable
  include Forkable

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

  # Methods

  def consent!(data_uri)
    save_signature!(data_uri)
    update consented_at: Time.zone.now
  end

  def consented?
    !consented_at.nil?
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

  def send_welcome_email_in_background(pw)
    fork_process(:send_welcome_email, pw)
  end

  def send_welcome_email(pw)
    RegistrationMailer.welcome_email(self, pw).deliver_now if EMAILS_ENABLED
  end
end
