# frozen_string_literal: true

# Displays settings pages.
class SettingsController < ApplicationController
  before_action :authenticate_user!

  layout "full_page"

  # # GET /settings
  # def settings
  # end

  # # GET /settings/password
  # def password
  # end

  # # GET /settings/leave-study
  # def leave_study
  # end
end
