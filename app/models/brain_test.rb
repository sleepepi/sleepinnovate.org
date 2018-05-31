# frozen_string_literal: true

# Tracks what Test My Brain tests a user has completed.
class BrainTest < ApplicationRecord
  # Scopes
  scope :active_tests, -> {
    where(
      battery_number: User::TEST_MY_BRAIN_SURVEYS.collect { |h| h[:battery_number] },
      test_number: User::TEST_MY_BRAIN_SURVEYS.collect { |h| h[:test_numbers] }.flatten
    )
  }

  # Validations
  validates :user_id, uniqueness: { scope: [:event, :battery_number, :test_number] }

  # Relationships
  belongs_to :user
end
