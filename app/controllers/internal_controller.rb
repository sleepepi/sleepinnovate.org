# frozen_string_literal: true

# Displays internal pages.
class InternalController < ApplicationController
  before_action :authenticate_user!

  layout "full_page"

  # POST /consent
  def submit_consent
    current_user.consent!(params[:data_uri])
    redirect_to dashboard_path
  end

  # DELETE /consent
  def revoke_consent
    current_user.revoke_consent!
    redirect_to dashboard_path, notice: "You have successfully withdrawn from the SleepINNOVATE study."
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
    slice_survey = current_user.survey_path(params[:sheet_id])
    if slice_survey
      redirect_to slice_survey
    else
      redirect_to dashboard_path, notice: "Survey could not be loaded."
    end
  end

  # # GET /awards
  # def awards
  # end

  # # GET /biobank
  # def biobank
  # end

  # # GET /dashboard
  # def dashboard
  # end

  # # GET /consents
  # def consents
  # end

  # # GET /survey
  # def survey
  # end

  # # GET /thank-you
  # def thank_you
  # end

  # # GET /test-my-brain
  # def test_my_brain
  # end
end
