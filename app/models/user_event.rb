# frozen_string_literal: true

# Tracks notification emails for user events.
class UserEvent < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :event
end
