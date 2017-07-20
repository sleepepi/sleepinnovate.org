# frozen_string_literal: true

# Tracks a series of events on a design.
class EventDesign
  attr_accessor :subject_event, :json, :id, :name, :sheets, :design_id

  def initialize(json, subject_event)
    @subject_event = subject_event
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

  def complete?
    @sheets.count { |s| s.percent == 100 }.positive?
  end

  def percent
    @sheets.first ? @sheets.first.percent : 0
  end

  def sheets_where(sheet_id)
    @sheets.select { |s| s.id.to_i == sheet_id.to_i }
  end
end
