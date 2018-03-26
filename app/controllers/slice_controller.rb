# frozen_string_literal: true

# Allows users to access Slice surveys.
class SliceController < ApplicationController
  # before_action :authenticate_user!
  # before_action :find_project_or_redirect, only: [
  #   :consent, :print_consent, :enrollment_consent, :enrollment_exit,
  #   :overview, :overview_report, :print_overview_report, :leave_study,
  #   :submit_leave_study
  # ]
  before_action :find_subject_or_redirect, only: [
    # :overview, :overview_report,
    :print_overview_report #,
    # :leave_study, :submit_leave_study
  ]

  # GET /research/:project/overview-report.pdf
  def print_overview_report
    redirect_to slice_research_path unless current_user
    variables = promis_disturbance_variables + promis_impairment_variables + meq_variables + wpai_variables + well_being_pcornet_variables + bmi_variables
    @data = @subject.data(variables)
    pdf_file = Rails.root.join(@subject.generate_overview_report_pdf!(@data))
    if File.exist?(pdf_file)
      send_file(pdf_file, filename: "SleepINNOVATESleepReport.pdf", type: "application/pdf", disposition: "inline")
    else
      redirect_to dashboard_path, alert: "Unable to generate PDF at this time."
    end
  end

  private

  def find_subject_or_redirect
    # @subject = @project.subjects.find_by(user: current_user)
    @subject = current_user.subject
    empty_response_or_root_path(root_path) unless @subject
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
