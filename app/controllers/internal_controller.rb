# frozen_string_literal: true

# Displays internal pages.
class InternalController < ApplicationController
  before_action :authenticate_user!
  before_action :check_parking_voucher, only: :parking
  before_action :check_unconsented, only: [:consent_signature, :submit_consent]
  before_action :check_consented, only: :surveys
  before_action :check_not_first_login, only: :surveys

  layout "full_page"

  # GET /consent/signature
  def consent_signature
    render layout: "full_page_no_header_no_footer"
  end

  # POST /consent
  def submit_consent
    current_user.consent!(params[:data_uri])
    if current_user.consented?
      redirect_to profile_complete_path
    else
      render :consent_signature
    end
  end

  # DELETE /consent
  def revoke_consent
    current_user.revoke_consent!
    notice = \
      if current_user.refused?
        "You refused to join the SleepINNOVATE study."
      else
        "You left the SleepINNOVATE study."
      end
    redirect_to dashboard_path, notice: notice
  end

  # GET /signature
  def signature
    send_file File.join(CarrierWave::Uploader::Base.root, current_user.consent_signature.url)
  end

  # GET /returning-from/:location/:subject_code
  def returning_from
    flash[:notice] = "Welcome back from TestMyBrain!" if params[:location] == "test-my-brain"
    redirect_to dashboard_path
  end

  # # GET /awards
  # def awards
  # end

  # # GET /dashboard
  # def dashboard
  # end

  # # GET /parking-voucher
  # def parking
  # end

  # # GET /surveys
  # def surveys
  # end

  # # GET /test-my-brain
  # def test_my_brain
  # end

  # POST /test-my-brain/start
  def test_my_brain_start
    current_user.test_my_brain_started!
    redirect_to "#{ENV["test_my_brain_url"]}?id=#{current_user.subject_code}"
  end

  # POST /test-my-brain/complete
  def test_my_brain_complete
    current_user.test_my_brain_completed!
    redirect_to dashboard_path
  end

  # POST /biobank/start
  def biobank_start
    current_user.biobank_registration_started!
    redirect_to ENV["biobank_url"]
  end

  # POST /biobank/complete
  def biobank_complete
    current_user.biobank_registration_completed!
    redirect_to dashboard_path
  end

  private

  def check_parking_voucher
    redirect_to dashboard_path unless current_user.parking_voucher?
  end

  def check_unconsented
    redirect_to consent_path unless current_user.unconsented?
  end
end
