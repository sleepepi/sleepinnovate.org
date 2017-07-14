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
