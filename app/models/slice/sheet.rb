# frozen_string_literal: true

# Tracks a sheet on a subject_event event for a subject.
class Sheet
  attr_accessor :json, :id, :name, :project_id, :design_id, :subject_id,
                :subject_event_id, :authentication_token, :response_count,
                :total_response_count, :percent, :missing, :created_at,
                :updated_at, :design_slug

  def initialize(json)
    load_sheet_from_json(json)
  end

  def path
    "#{ENV['slice_url']}/survey/#{@design_slug}/#{@authentication_token}"
  end

  private

  def load_sheet_from_json(json)
    return unless json
    @json = json
    root_attributes.each do |attribute|
      send("#{attribute}=", json[attribute.to_s])
    end
  end

  def root_attributes
    [
      :id,
      :name,
      :project_id,
      :design_id,
      :subject_id,
      :subject_event_id,
      :authentication_token,
      :response_count,
      :total_response_count,
      :percent,
      :missing,
      :created_at,
      :updated_at,
      :design_slug
    ]
  end
end
