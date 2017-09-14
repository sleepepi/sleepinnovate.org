# frozen_string_literal: true

# Tracks subject events and form completion.
class Subject < SliceRecord
  attr_accessor :json, :id, :subject_code, :user

  def initialize(user)
    @user = user
    set_defaults
    find_or_create_subject
  end

  def current_event
    "Baseline"
  end

  def total_baseline_surveys_count
    if baseline_event
      baseline_event.event_designs.size
    else
      0
    end
  end

  def baseline_surveys_completed_count
    if baseline_event
      baseline_event.event_designs.count(&:complete?)
    else
      0
    end
  end

  def baseline_surveys_completed?
    if baseline_event
      baseline_event.event_designs.count(&:incomplete?).zero?
    else
      false
    end
  end

  def baseline_event
    current_subject_event("Baseline")
  end

  def current_subject_event(subject_event_name)
    subject_events.find { |se| se.name == subject_event_name }
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
    return [] unless linked?
    (json, status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/events.json")
    load_events_from_json(json, status)
  end

  def launch_survey!(subject_event_id, design_id, remote_ip)
    params = { subject_event_id: subject_event_id, design_id: design_id, remote_ip: remote_ip }
    (json, _status) = Helpers::JsonRequest.post("#{project_url}/subjects/#{@id}/sheets.json", params)
    json["id"]
  end

  def next_survey
    @next_survey ||= begin
      event = subject_events.find { |se| se.percent != 100 }
      event.event_designs.find { |ed| !ed.complete? } if event
    end
  end

  def start_event_survey(event, design)
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}.json")
    # return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  def resume_event_survey(event, design)
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/resume.json")
    # return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  def page_event_survey(event, design, page)
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/#{page}.json")
    # return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  def submit_response_event_survey(event, design, page, response, remote_ip)
    params = { _method: "patch", response: response, remote_ip: remote_ip }
    Helpers::JsonRequest.post("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/#{page}.json", params)
  end

  def complete_event_survey(event, design)
    start_event_survey(event, design)
  end

  private

  def set_defaults
    @id = @user.slice_subject_id
  end

  def linked?
    @id.present?
  end

  def find_or_create_subject
    return unless @user.consented?
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
    "#{ENV["code_prefix"]}#{format("%05d", next_subject_code_number)}"
  end

  def next_subject_code_number
    highest_subject_code_number + 1
  end

  def highest_subject_code_number
    all_subject_codes.collect { |c| c.gsub(ENV["code_prefix"], "").to_i }.max || 0
  end

  def all_subject_codes
    @all_codes ||= begin
      all_codes = []
      page = 1
      loop do
        new_subject_codes = subject_codes_on_page(page)
        all_codes += new_subject_codes.reject { |c| (/^#{ENV["code_prefix"]}\d{5}$/ =~ c).nil? }
        page += 1
        break unless new_subject_codes.size == 20
      end
      all_codes
    end
  end

  def subject_codes_on_page(page)
    params = { page: page }
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects.json", params)
    return [] unless json
    subject_codes = json.collect do |subject_json|
      subject_json["subject_code"]
    end
    subject_codes
  end

  # Returns array of [:user_id, :subject_code] pairs.
  def self.remote_subjects
    @remote_subjects ||= begin
      subjects = []
      page = 1
      loop do
        new_subjects = subjects_on_page(page)
        subjects += new_subjects
        page += 1
        break unless new_subjects.size == 20
      end
      subjects
    end
  end

  def self.subjects_on_page(page)
    params = { page: page }
    (json, _status) = Helpers::JsonRequest.get("#{SliceRecord.new.project_url}/subjects.json", params)
    return [] unless json
    subjects = json.collect do |subject_json|
      [subject_json["id"], subject_json["subject_code"]]
    end
    subjects
  end

  def self.remote_subject_code(user)
    subject = remote_subjects.find { |user_id, _code| user_id == user.slice_subject_id }
    subject.last if subject
  end
end
