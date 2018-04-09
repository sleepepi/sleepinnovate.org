# frozen_string_literal: true

SLEEP_REPORT_ENABLED = \
  if Rails.env.test?
    false
  else
    ENV["sleep_report_enabled"] == "true"
  end
