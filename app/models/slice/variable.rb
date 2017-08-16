# frozen_string_literal: true

# Helps contain information about a question on a survey.
class Variable
  attr_accessor :json, :id, :name, :display_name, :variable_type

  def initialize(json: {})
    load_from_json(json) if json.present?
  end

  def load_from_json(json)
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
      :display_name,
      :variable_type
    ]
  end
end
