# frozen_string_literal: true

# Tracks a sheet on a subject_event event for a subject.
class Sheet
  attr_accessor :json, :id, :name, :authentication_token, :percent

  def initialize(json)
    @json = json
    @id = json["id"]
    @name = json["name"]
    @authentication_token = json["authentication_token"]
    @percent = json["percent"]
    @design_slug = json["design_slug"]
  end

  def path
    "#{ENV['slice_url']}/survey/#{@design_slug}/#{@authentication_token}"
  end
end
