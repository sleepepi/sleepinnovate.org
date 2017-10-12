# frozen_string_literal: true

# Tracks survey completion.
class UserSurvey < ApplicationRecord
  # Relationships
  belongs_to :user

  # Methods
end
