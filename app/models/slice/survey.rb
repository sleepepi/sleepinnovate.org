# frozen_string_literal: true

# Helps contain information about a survey.
class Survey
  attr_accessor :json, :id, :name

  def initialize(json: {})
    load_from_json(json) if json.present?
  end

  def load_from_json(json)
    return unless json
    json = json.dig("design") # TODO: Remove
    @json = json
    root_attributes.each do |attribute|
      send("#{attribute}=", json[attribute.to_s])
    end
  end

  def root_attributes
    [
      :id,
      :name
    ]
  end
end
