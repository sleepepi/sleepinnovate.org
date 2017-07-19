# frozen_string_literal: true

# Tracks a series of events on a design.
class EventDesign
  attr_accessor :json, :id, :name, :sheets, :design_id

  def initialize(json)
    @json = json
    @id = json["id"]
    @name = json["name"]
    @design_id = json["design_id"]
    @sheets = load_sheets(json["sheets"])
  end

  def load_sheets(json_sheets)
    if json_sheets
      json_sheets.collect do |json|
        Sheet.new(json)
      end
    else
      []
    end
  end
end
