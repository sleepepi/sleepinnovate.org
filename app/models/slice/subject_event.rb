# frozen_string_literal: true

# Tracks a series of designs filled out on an event date for a subject.
class SubjectEvent
  attr_accessor :json, :id, :name, :event_designs, :percent, :unblinded_responses_count, :unblinded_questions_count

  def initialize(json)
    @json = json
    @id = json["id"]
    @name = json["name"]
    @unblinded_percent = json["unblinded_percent"]
    @unblinded_responses_count = json["unblinded_responses_count"]
    @unblinded_questions_count = json["unblinded_questions_count"]
    @event_designs = load_event_designs(json["event_designs"])
  end

  def percent
    @unblinded_percent
  end

  def load_event_designs(json_event_designs)
    if json_event_designs
      json_event_designs.collect do |json|
        EventDesign.new(json)
      end
    else
      []
    end
  end
end
