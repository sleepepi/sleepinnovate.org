# frozen_string_literal: true

require "simplecov"
require "minitest/pride"

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

# Set up ActiveSupport tests.
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Set up ActionDispatch tests.
class ActionDispatch::IntegrationTest
  setup do
    Artifice.activate_with(slice_generic_response)
  end

  teardown do
    Artifice.deactivate
  end

  def login(user)
    sign_in_as(user, "PASSword1")
  end

  def sign_in_as(user, password)
    user.update(password: password, password_confirmation: password)
    post new_user_session_url, params: { user: { email: user.email, password: password } }
    follow_redirect!
    user
  end

  def slice_generic_response
    proc do |env|
      project_url = "#{URI(ENV["slice_url"]).path}/api/v1/projects/#{ENV["project_id"]}-#{ENV["project_auth_token"]}"
      case "#{env["PATH_INFO"]}?#{env["QUERY_STRING"]}"
      when "#{project_url}/subjects.json?page=1"
        subjects_json
      when "#{project_url}/subjects.json?"
        subject_json
      when "#{project_url}/subjects/3/events.json?"
        subject_events_json
      else
        if /^\/session/ =~ env["PATH_INFO"] || /^\/__identify__/ =~ env["PATH_INFO"]
          Artifice.passthru!
        else
          # puts "#{env["PATH_INFO"]}?#{env["QUERY_STRING"]}"
          fail Net::ReadTimeout
          # [
          #   200,
          #   { "Content-Type" => "application/json" },
          #   [{ success: true }.to_json]
          # ]
        end
      end
    end
  end

  def subjects_json
    [
      200,
      { "Content-Type" => "application/json" },
      [
        [
          { id: 1, subject_code: "#{ENV["code_prefix"]}00001" },
          { id: 2, subject_code: "#{ENV["code_prefix"]}00002" }
        ].to_json
      ]
    ]
  end

  def subject_json
    [
      201,
      { "Content-Type" => "application/json" },
      [
        { id: 3, subject_code: "#{ENV["code_prefix"]}00003" }.to_json
      ]
    ]
  end

  def subject_events_json
    [
      200,
      { "Content-Type" => "application/json" },
      [
        [
          {
            id: 1,
            name: "Baseline",
            event_id: 207,
            event_date: "2017-01-01",
            unblinded_responses_count: 1,
            unblinded_questions_count: 10,
            unblinded_percent: 10,
            event: "baseline",
            event_designs: [
              {
                event: {
                  name: "Baseline",
                  id: "baseline"
                },
                design: {
                  name: "Intake Questionnaire",
                  id: "intake"
                },
                sheets: []
              }
            ]
          }
        ].to_json
      ]
    ]
  end
end

module Rack
  module Test
    # Allow files to be uploaded in tests
    class UploadedFile
      attr_reader :tempfile
    end
  end
end
