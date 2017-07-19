# frozen_string_literal: true

# Tracks subject events and form completion.
class Subject < SliceRecord
  attr_accessor :json, :id, :subject_code, :user

  def initialize(user)
    @user = user
    set_defaults
    find_or_create_subject
  end

  def loaded?
    @id.present?
  end

  def subject_events
    @subject_events ||= begin
      load_subject_events
    end
  end

  def load_subject_events
    (json, status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/events.json")
    load_events_from_json(json, status)
  end

  def launch_survey!(subject_event_id, design_id, remote_ip)
    params = { subject_event_id: subject_event_id, design_id: design_id, remote_ip: remote_ip }
    (json, status) = Helpers::JsonRequest.post("#{project_url}/subjects/#{@id}/sheets.json", params)
    json["id"]
  end

  def next_survey
    @next_survey ||= begin
      event = subject_events.find { |se| se.percent != 100 }
      event.event_designs.find { |ed| !ed.complete? } if event
    end
  end

  private

  def set_defaults
    @id = @user.slice_subject_id
  end

  def linked?
    @id.present?
  end

  def find_or_create_subject
    if linked?
      load_remote_subject
    else
      create_remote_subject
      create_baseline_event
    end
  end

  def load_remote_subject
    (json, status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}.json")
    load_subject_from_json(json, status)
  end

  def create_remote_subject
    params = {
      subject: {
        subject_code: generate_subject_code,
        site_id: ENV["site_id"]
      }
    }
    (json, status) = Helpers::JsonRequest.post("#{project_url}/subjects.json", params)
    load_subject_from_json(json, status)
    link_subject
  end

  def load_subject_from_json(json, status)
    return unless status.is_a?(Net::HTTPSuccess)
    return unless json
    @json = json
    root_attributes.each do |attribute|
      send("#{attribute}=", json[attribute.to_s])
    end
  end

  def link_subject
    @user.update slice_subject_id: @id if @id.present?
  end

  def root_attributes
    [:id, :subject_code]
  end

  def create_baseline_event
    return unless linked?
    params = { event_id: ENV["baseline_id"] }
    (json, status) = Helpers::JsonRequest.post("#{project_url}/subjects/#{@id}/events.json", params)
    load_events_from_json(json, status)
  end

  def load_events_from_json(json, status)
    return [] unless status.is_a?(Net::HTTPSuccess)
    return [] unless json
    json.collect do |subject_event|
      SubjectEvent.new(subject_event)
    end
  end

  def generate_subject_code
    "S#{format('%05d', subject_count)}-#{SecureRandom.hex(2)}"
  end

  def subject_count
    User.where.not(slice_subject_id: nil).count + 1
  end
end
