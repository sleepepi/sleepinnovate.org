# frozen_string_literal: true

# Tracks subject events and form completion.
class Subject < SliceRecord
  attr_accessor :json, :id, :subject_code, :user

  def initialize(user)
    @user = user
    set_defaults
    find_or_create_subject
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
    subject_events.find { |se| se.name == "Baseline" }
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

  def survey_path(sheet_id)
    sheet = subject_events.collect { |se| se.sheets_where(sheet_id) }.flatten.first
    "#{ENV['slice_url']}/survey/#{sheet.design_slug}/#{sheet.authentication_token}" if sheet
  end

  def start_event_survey(event, design)
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}.json")
    # return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  def page_event_survey(event, design, page)
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/#{page}.json")
    # return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  def submit_response_event_survey(event, design, page, response)
    params = { _method: "patch", response: response }
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
    "INN#{format('%05d', next_subject_code_number)}"
  end

  def next_subject_code_number
    highest_subject_code_number + 1
  end

  def highest_subject_code_number
    all_subject_codes.collect { |c| c.gsub("INN", "").to_i }.max || 0
  end

  def all_subject_codes
    @all_codes ||= begin
      all_codes = []
      page = 1
      loop do
        new_subject_codes = subject_codes_on_page(page)
        all_codes += new_subject_codes.reject { |c| (/^INN\d{5}$/ =~ c).nil? }
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
end
