# frozen_string_literal: true

# Tracks subject events and form completion.
class Subject < SliceRecord
  attr_accessor :json, :id, :subject_code

  def initialize(subject_id, current_user)
    (json, _status) = find_or_create_subject(subject_id, current_user)
    if json
      @subject_code = json["subject_code"]
      @id = json["id"]
    end
    @json = json
  end

  def subject_events
    @subject_events ||= begin
      load_subject_events
    end
  end

  def load_subject_events
    (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{@id}/events.json")
    if json
      json.collect do |subject_event|
        SubjectEvent.new(subject_event)
      end
    else
      []
    end
  end

  private

  def find_or_create_subject(subject_id, current_user)
    if subject_id.present?
      (json, _status) = Helpers::JsonRequest.get("#{project_url}/subjects/#{subject_id}.json")
    else
      params = {
        subject: {
          subject_code: "S#{format('%05d', User.where.not(slice_subject_id: nil).count + 1)}-#{SecureRandom.hex(2)}",
          site_id: ENV["site_id"]
        }
      }
      (json, _status) = Helpers::JsonRequest.post("#{project_url}/subjects.json", params)
      if json && json["id"].present?
        current_user.update slice_subject_id: json["id"]
      end
      [json, _status]
    end
  end

  def create_baseline_event
    params = {
      event_id: ENV["baseline_id"]
    }
    (json, _status) = Helpers::JsonRequest.post("#{project_url}/subjects/#{@id}/events.json", params)
  end
end
