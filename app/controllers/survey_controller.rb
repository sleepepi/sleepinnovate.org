# frozen_string_literal: true

# Displays survey pages.
class SurveyController < ApplicationController
  before_action :authenticate_user!
  before_action :check_consented
  before_action :find_page, only: [:page, :submit_page]

  layout "full_page"

  # GET /survey/:event/:design/start
  def start
    # @json = current_user.start_event_survey(params[:event], params[:design])
    # @survey = Survey.new(json: @json)
    survey_in_progress
    redirect_to survey_page_path(params[:event], params[:design], 1)
  end

  # GET /survey/:event/:design/:page
  def page
    @json = current_user.page_event_survey(params[:event], params[:design], @page)
    @survey = Survey.new(json: @json)
    if @json.present?
      @section = Section.new(json: @json.dig("section")) if @json.dig("section").present?
      @variable = Variable.new(json: @json.dig("variable")) if @json.dig("variable").present?
    end
    redirect_to survey_review_path(params[:event], params[:design]) if @json.blank?
  end

  # GET /survey/:event/:design/:resume
  def resume
    survey_in_progress
    @json = current_user.resume_event_survey(params[:event], params[:design])
    @survey = Survey.new(json: @json)
    if @json.blank?
      redirect_to survey_review_path(params[:event], params[:design])
    else
      @page = @json.dig("design", "current_page")
      @section = Section.new(json: @json.dig("section")) if @json.dig("section").present?
      @variable = Variable.new(json: @json.dig("variable")) if @json.dig("variable").present?
      render :page
    end
  end

  # PATCH /survey/:event/:design/:page
  def submit_page
    if params[:response].is_a?(ActionController::Parameters)
      value = {
        day: params[:response][:day],
        month: params[:response][:month],
        year: params[:response][:year],
        hours: params[:response][:hours],
        minutes: params[:response][:minutes],
        seconds: params[:response][:seconds],
        period: params[:response][:period],
        pounds: params[:response][:pounds],
        ounces: params[:response][:ounces],
        feet: params[:response][:feet],
        inches: params[:response][:inches]
      }
    else
      value = params[:response]
    end
    (@json, @status) = current_user.submit_response_event_survey(params[:event], params[:design], @page, value, request.remote_ip)
    if @status.is_a?(Net::HTTPOK)
      if params[:review] == "1"
        redirect_to survey_review_path(params[:event], params[:design])
      else
        redirect_to survey_page_path(params[:event], params[:design], @page + 1)
      end
    elsif @json
      @section = Section.new(json: @json.dig("section")) if @json.dig("section").present?
      @variable = Variable.new(json: @json.dig("variable")) if @json.dig("variable").present?
      render :page
    else
      redirect_to survey_page_path(params[:event], params[:design], @page)
    end
  end

  # GET /survey/:event/:design/review
  def review
    (@json, @status) = current_user.review_event_survey(params[:event].downcase, params[:design].downcase)
  end

  # POST /survey/:event/:design/review
  def complete
    survey_completed
    if current_user.next_survey
      redirect_to survey_start_path(current_user.next_survey.event_id, current_user.next_survey.design_id)
    else
      redirect_to dashboard_path
    end
  end

  private

  def find_user_survey
    current_user.user_surveys.where(event: params[:event].downcase, design: params[:design].downcase).first_or_create
  end

  def survey_in_progress
    find_user_survey.update(completed: false)
  end

  def survey_completed
    find_user_survey.update(completed: true)
  end

  def find_page
    @page = [params[:page].to_i, 1].max
  end
end
