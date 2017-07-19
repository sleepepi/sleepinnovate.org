# frozen_string_literal: true

# Displays internal pages.
class InternalController < ApplicationController
  before_action :authenticate_user!

  # GET /consent
  def consent
    render layout: "layouts/full_page"
  end

  # POST /consent
  def submit_consent
    current_user.consent!(params[:data_uri])
    redirect_to dashboard_path
  end

  # GET /signature
  def signature
    send_file File.join(CarrierWave::Uploader::Base.root, current_user.consent_signature.url)
  end

  # POST /start-survey
  def start_survey
    subject_event_id = params[:subject_event_id]
    design_id = params[:design_id]
    sheet_id = current_user.launch_survey!(subject_event_id, design_id, request.remote_ip)

    redirect_to show_survey_path(
      subject_event_id: subject_event_id, design_id: design_id, sheet_id: sheet_id
    )
  end

  # GET /show-survey
  def show_survey
    # redirect_to "#{ENV['slice_url']}/survey/#{design_slug}/#{sheet.token}"
  end

  # # GET /dashboard
  # def dashboard
  # end

  # # GET /survey
  # def survey
  # end

  # # GET /thank-you
  # def thank_you
  # end
end
