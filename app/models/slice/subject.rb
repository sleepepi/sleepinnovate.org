# frozen_string_literal: true

# Tracks subject events and form completion.
class Subject < SliceRecord
  # Concerns
  include Latexable
  include Reportable

  attr_accessor :json, :id, :subject_code, :user

  def initialize(user)
    @user = user
    set_defaults
    find_or_create_subject
  end

  def current_event
    Event.find_by(slug: subject_events.last&.event)
  end

  def event_launched?(event)
    current_subject_event(event.slug).present?
  end

  def event_surveys_completed(event)
    subject_event = current_subject_event(event.slug)
    return 0 unless subject_event
    subject_event.event_designs.count { |ed| ed.complete?(@user) }
  end

  def event_surveys_total(event)
    subject_event = current_subject_event(event.slug)
    return 0 unless subject_event
    subject_event.event_designs.count
  end

  def event_completed?(event)
    subject_event = current_subject_event(event.slug)
    return false unless subject_event
    subject_event.complete?(@user)
  end

  def current_subject_event(subject_event_slug)
    subject_events.find { |se| se.event == subject_event_slug }
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
    (json, status) = Slice::JsonRequest.get("#{project_url}/subjects/#{@id}/events.json")
    load_events_from_json(json, status)
  end

  def launch_survey!(subject_event_id, design_id, remote_ip)
    params = { subject_event_id: subject_event_id, design_id: design_id, remote_ip: remote_ip }
    (json, _status) = Slice::JsonRequest.post("#{project_url}/subjects/#{@id}/sheets.json", params)
    json["id"]
  end

  def next_survey
    @next_survey ||= begin
      subject_events.last&.event_designs&.find { |ed| !ed.complete?(@user) }
    end
  end

  def resume_event_survey(event, design)
    Slice::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/resume.json")
  end

  def page_event_survey(event, design, page)
    Slice::JsonRequest.get("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/#{page}.json")
  end

  def submit_response_event_survey(event, design, page, design_option_id, response, remote_ip)
    params = { _method: "patch", design_option_id: design_option_id, response: response, remote_ip: remote_ip }
    Slice::JsonRequest.post("#{project_url}/subjects/#{@id}/surveys/#{event}/#{design}/#{page}.json", params)
  end

  def review_event_survey(event, design)
    params = { subject_id: @id }
    Slice::JsonRequest.get("#{project_url}/reports/review/#{event}/#{design}.json", params)
  end

  def report_event_survey(event, design)
    params = { subject_id: @id }
    Slice::JsonRequest.get("#{project_url}/reports/#{event}/#{design}.json", params)
  end

  def create_event!(event)
    return unless linked?
    return if event_launched?(event)
    params = { event_id: event.slug }
    (json, status) = Slice::JsonRequest.post("#{project_url}/subjects/#{@id}/events.json", params)
    load_events_from_json(json, status)
  end

  def data(data_points)
    params = { data_points: data_points }
    (json, status) = Slice::JsonRequest.get("#{project_url}/subjects/#{@id}/data.json", params)
    return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  # Print Consent
  def latex_partial(partial)
    File.read(File.join("app", "views", "subjects", "latex", "_#{partial}.tex.erb"))
  end

  def generate_overview_report_pdf!(data)
    jobname = "overview_report"
    temp_dir = Dir.mktmpdir
    temp_tex = File.join(temp_dir, "#{jobname}.tex")

    write_tex_file(temp_tex, data)
    self.class.compile(jobname, temp_dir, temp_tex)
    temp_pdf = File.join(temp_dir, "#{jobname}.pdf")

    @user.update overview_report_pdf: File.open(temp_pdf, "r"), overview_report_pdf_file_size: File.size(temp_pdf)
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def write_tex_file(temp_tex, data)
    # Needed by binding
    @subject = self
    @data = data
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("header")).result(binding))
      file.syswrite(ERB.new(latex_partial("overview_report")).result(binding))
      file.syswrite(ERB.new(latex_partial("footer")).result(binding))
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
    return load_remote_subject if linked?
    return if @user.consented_at.nil?
    create_remote_subject
    create_baseline_event
  end

  def load_remote_subject
    (json, status) = Slice::JsonRequest.get("#{project_url}/subjects/#{@id}.json")
    load_subject_from_json(json, status)
  end

  def create_remote_subject
    params = {
      subject: {
        subject_code: generate_subject_code,
        site_id: ENV["site_id"]
      }
    }
    (json, status) = Slice::JsonRequest.post("#{project_url}/subjects.json", params)
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
    params = { event_id: Event.first.slug }
    (json, status) = Slice::JsonRequest.post("#{project_url}/subjects/#{@id}/events.json", params)
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
    (json, _status) = Slice::JsonRequest.get("#{project_url}/subjects.json", params)
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

  def self.remote_subjects_clear
    @remote_subjects = nil
  end

  def self.subjects_on_page(page)
    params = { page: page }
    (json, _status) = Slice::JsonRequest.get("#{SliceRecord.new.project_url}/subjects.json", params)
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

  def self.slice_online?
    (_json, status) = Slice::JsonRequest.get("#{SliceRecord.new.project_url}.json")
    status.is_a?(Net::HTTPSuccess)
  end

  def self.slice_offline?
    !slice_online?
  end
end
