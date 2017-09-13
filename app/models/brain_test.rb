# frozen_string_literal: true

# Tracks what Test My Brain tests a user has completed.
class BrainTest < ApplicationRecord
  # Relationships
  belongs_to :user
end
