# frozen_string_literal: true

namespace :admin do
  desc "Export for admin interface."
  task export: :environment do
    csv_file = Rails.root.join("admin", "admin.csv")
    CSV.open(csv_file, "wb") do |csv|
      csv << [
        "SleepINNOVATE ID", "Slice Subject Code", "Full Name", "Email",
        "Date of Birth", "Address", "Clinic", "Consent Status", "Consented At",
        "Consent Revoked At"
      ]
      User.consented.order(:id).find_each do |user|
        csv << [
          user.id,
          Subject.remote_subject_code(user),
          user.full_name,
          user.email,
          format_date(user.dob),
          user.address,
          user.clinic,
          user.status,
          format_datetime(user.consented_at),
          format_datetime(user.consent_revoked_at)
        ]
      end
    end
    export_email_notifications
  end
end

def format_datetime(datetime_at)
  return unless datetime_at
  datetime_at.strftime("%Y-%m-%d %H:%M:%S")
end

def format_date(date)
  return unless date
  date.strftime("%Y-%m-%d")
end

def export_email_notifications
  csv_file = Rails.root.join("admin", "email_notifications.csv")
  CSV.open(csv_file, "wb") do |csv|
    csv << ["SleepINNOVATE ID", "Event", "Activation Sent", "Reminder Sent"]
    UserEvent.includes(:event).each do |user_event|
      csv << [
        Subject.remote_subject_code(user_event.user),
        user_event.event.slug,
        format_datetime(user_event.activation_email_sent_at),
        format_datetime(user_event.reminder_email_sent_at)
      ]
    end
  end
end
