# frozen_string_literal: true

# Tracks survey completion.
class UserSurvey < ApplicationRecord
  # Validations
  validates :user_id, uniqueness: { scope: [:event, :design] }

  # Relationships
  belongs_to :user
end
