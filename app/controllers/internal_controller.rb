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

  # GET /dashboard
  def dashboard
    if current_user.consented?
      variables = promis_disturbance_variables + promis_impairment_variables + meq_variables + wpai_variables + well_being_pcornet_variables + bmi_variables
      @data = current_user.subject.data(variables)
    end
  end

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
    redirect_to "#{ENV["test_my_brain_url"]}?id=#{current_user.subject_code}#{current_user.current_event_brain_code}", allow_other_host: true
  end

  # POST /biobank/start
  def biobank_start
    current_user.biobank_registration_started!
    redirect_to ENV["biobank_url"], allow_other_host: true
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

  def promis_disturbance_variables
    [
      { event: "baseline", variable: "quality_sleep_quality" },
      { event: "baseline", variable: "quality_refreshing" },
      { event: "baseline", variable: "quality_problem" },
      { event: "baseline", variable: "quality_difficulty" },
      { event: "baseline", variable: "quality_restless" },
      { event: "baseline", variable: "quality_tried_hard" },
      { event: "baseline", variable: "quality_worried" },
      { event: "baseline", variable: "quality_satisfied" }
    ]
  end

  def promis_impairment_variables
    [
      { event: "baseline", variable: "quality_sleepy" },
      { event: "baseline", variable: "quality_alert_woke" },
      { event: "baseline", variable: "quality_tired" },
      { event: "baseline", variable: "quality_problems" },
      { event: "baseline", variable: "quality_concentrating" },
      { event: "baseline", variable: "quality_irritable" },
      { event: "baseline", variable: "quality_sleepy_daytime" },
      { event: "baseline", variable: "quality_staying_awake" }
    ]
  end

  def meq_variables
    [
      { event: "baseline", variable: "daynight_feeling_best" }
    ]
  end

  def wpai_variables
    [
      { event: "baseline", variable: "work_sick_missed_work" },
      { event: "baseline", variable: "work_working_hours" },
      { event: "baseline", variable: "work_productivity" },
      { event: "baseline", variable: "work_leisure" }
    ]
  end

  def well_being_pcornet_variables
    [
      { event: "baseline", variable: "general_depressed" },
      { event: "baseline", variable: "general_fatigued" },
      { event: "baseline", variable: "general_mental_health" },
      { event: "baseline", variable: "general_uneasy" }
    ]
  end

  def bmi_variables
    [
      { event: "baseline", variable: "demo_height" },
      { event: "baseline", variable: "demo_weight" }
    ]
  end
end
