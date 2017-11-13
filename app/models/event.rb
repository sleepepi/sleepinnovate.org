# frozen_string_literal: true

# Tracks baseline and followup events.
class Event < ApplicationRecord
  # Relationships
  has_many :user_events
end
