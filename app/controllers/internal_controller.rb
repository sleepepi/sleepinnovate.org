# frozen_string_literal: true

# Displays internal pages.
class InternalController < ApplicationController
  before_action :authenticate_user!
  before_action :check_parking_voucher, only: :parking
  before_action :check_consented, only: [:surveys, :leave_study, :submit_leave_study]
  before_action :check_not_first_login, only: :surveys

  layout "full_page"

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

  # # GET /leave-study
  # def leave_study
  # end

  # POST /leave-study
  def submit_leave_study
    if params[:withdraw].to_s.casecmp("withdraw").zero?
      current_user.revoke_consent!
      redirect_to dashboard_path, notice: "You left the SleepINNOVATE study."
    else
      @withdraw_error = true
      render :leave_study
    end
  end

  # # GET /test-my-brain
  # def test_my_brain
  # end

  # POST /test-my-brain/start
  def test_my_brain_start
    current_user.test_my_brain_started!
    redirect_to "#{ENV["test_my_brain_url"]}?id=#{current_user.subject_code}#{current_user.current_event_brain_code}"
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
    redirect_to dashboard_path unless current_user.parking_voucher? && session[:clinic].present?
  end

  def check_unconsented
    redirect_to consent_path unless current_user.unconsented?
  end
end
