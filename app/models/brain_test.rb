# frozen_string_literal: true

# Tracks what Test My Brain tests a user has completed.
class BrainTest < ApplicationRecord
  # Validations
  validates :user_id, uniqueness: { scope: [:event, :battery_number, :test_number] }

  # Relationships
  belongs_to :user
end
