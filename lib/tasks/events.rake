# frozen_string_literal: true

namespace :events do
  desc "Generate all scheduled events."
  task populate: :environment do
    Event.where(slug: "baseline").first_or_create(
      name: "Baseline", month: 0, time_ago: ""
    )
    Event.where(slug: "followup-3month").first_or_create(
      name: "3-Month Follow-up", month: 3, time_ago: "Three months ago"
    )
    Event.where(slug: "followup-6month").first_or_create(
      name: "6-Month Follow-up", month: 6, time_ago: "Six months ago"
    )
    Event.where(slug: "followup-12month").first_or_create(
      name: "12-Month Follow-up", month: 12, time_ago: "One year ago"
    )
    Event.where(slug: "followup-24month").first_or_create(
      name: "24-Month Follow-up", month: 24, time_ago: "Two years ago"
    )
  end

  desc "Activate events and sent surveys available and surveys reminder emails."
  task followup: :environment do
    if Subject.slice_offline?
      User.where(admin: true).find_each do |user|
        SurveyMailer.followup_summary_failure(user).deliver_now if EMAILS_ENABLED
      end
      next # Quit
    end
    activations = []
    reminders = []
    events = Event.order(:month).to_a
    User.consented_with_testers.find_each do |user|
      activations_row = { subject: Subject.remote_subject_code(user), events: [] }
      reminders_row = { subject: Subject.remote_subject_code(user), events: [] }
      puts "#{Subject.remote_subject_code(user)}"
      events.each do |event|
        launched = event_launched?(event, user)
        if !launched && activate_event?(event, user)
          if activate_event!(event, user)
            activations_row[:events] << { event: event.name, days_after_consent: days_after_consent(user) }
          end
        else
          puts "Activation #{"SKIPPED".colorize(:white)}."
        end
        if launched && !user.event_completed?(event) && remind_event?(event, user)
          if remind_event!(event, user)
            reminders_row[:events] << { event: event.name, days_after_consent: days_after_consent(user) }
          end
        end
        puts ""
      end
      activations << activations_row if activations_row[:events].present?
      reminders << reminders_row if reminders_row[:events].present?
    end
    activations.sort_by! { |h| h[:subject].to_s }
    reminders.sort_by! { |h| h[:subject].to_s }
    if activations.present? || reminders.present?
      User.where(admin: true).find_each do |user|
        SurveyMailer.followup_summary(user, activations, reminders).deliver_now if EMAILS_ENABLED
      end
    end
    puts "Activations: #{activations}"
    puts "Reminders: #{reminders}"
  end

  def activate_event?(event, user)
    print "activate_event?(#{event.slug}, #{Subject.remote_subject_code(user)})"
    if user.consented_at.blank?
      puts " => #{false}".colorize(:red)
      return false
    end
    activation_date = user.consented_at.to_date + event.month.months
    result = activation_date <= Time.zone.today
    puts " => #{result}".colorize(result ? :green : :red)
    puts "#{days_after_consent(user)} days since consent. Activation needs at least #{(activation_date - user.consented_at.to_date).to_i} days."
    result
  end

  def event_launched?(event, user)
    print "event_launched?(#{event.slug}, #{Subject.remote_subject_code(user)})"
    if event.month.zero?
      user_event = user.user_events.where(event: event).first_or_create(activation_email_sent_at: user.consented_at)
    else
      user_event = user.user_events.find_by(event: event)
    end
    result = user_event&.activation_email_sent_at.present?
    puts " => #{result}".colorize(result ? :green : :red)
    result
  end

  def activate_event!(event, user)
    puts "activate_event!(#{event.slug}, #{Subject.remote_subject_code(user)})"
    user_event = user.user_events.where(event: event).first_or_create
    if user_event.activation_email_sent_at.blank?
      user_event.update(activation_email_sent_at: Time.zone.now)
      puts "#{Subject.remote_subject_code(user)}.create_event!(#{event.slug}) in Slice"
      user.create_event!(event)
      puts "Send #{Subject.remote_subject_code(user)} #{event.slug} activation email"
      SurveyMailer.surveys_available(user, event).deliver_now if EMAILS_ENABLED
      true
    else
      puts "Activateon email #{"SKIPPED".colorize(:white)}."
      puts "#{event.slug} already activated! No activation email sent."
      false
    end
  end

  def remind_event?(event, user)
    print "remind_event?(#{event.slug}, #{Subject.remote_subject_code(user)})"
    if user.consented_at.blank?
      puts " => #{false}".colorize(:red)
      return false
    end
    reminder_date = user.consented_at.to_date + event.month.months + 1.week
    result = reminder_date <= Time.zone.today
    puts " => #{result}".colorize(result ? :green : :red)
    puts "#{days_after_consent(user)} days since consent. Reminder needs at least #{(reminder_date - user.consented_at.to_date).to_i} days."
    result
  end

  def remind_event!(event, user)
    puts "remind_event!(#{event.slug}, #{Subject.remote_subject_code(user)})"
    user_event = user.user_events.where(event: event).first_or_create
    if user_event.reminder_email_sent_at.blank?
      user_event.update(reminder_email_sent_at: Time.zone.now)
      puts "Send #{Subject.remote_subject_code(user)} #{event.slug} reminder email"
      SurveyMailer.surveys_reminder(user, event).deliver_now if EMAILS_ENABLED
      true
    else
      puts "Reminder email #{"SKIPPED".colorize(:white)}."
      false
    end
  end

  def days_after_consent(user)
    return -1 if user.consented_at.blank?
    (Time.zone.today - user.consented_at.to_date).to_i
  end
end
