# frozen_string_literal: true

# Base ActiveRecord connection.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
