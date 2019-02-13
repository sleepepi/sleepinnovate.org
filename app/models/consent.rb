# frozen_string_literal: true

# Tracks different consents over time.
class Consent < ApplicationRecord
  # Methods
  def self.find_latest
    find_by end_date: nil
  end
end
