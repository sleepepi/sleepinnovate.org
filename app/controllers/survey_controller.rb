# frozen_string_literal: true

# Displays survey pages.
class SurveyController < ApplicationController
  before_action :authenticate_user!
  before_action :check_consented
  before_action :find_page, only: [:page, :submit_page]

  layout "full_page"

  # GET /survey/:event/:design/start
  def start
    @json = current_user.start_event_survey(params[:event], params[:design])
    @survey = Survey.new(json: @json)
  end

  # GET /survey/:event/:design/:page
  def page
    @json = current_user.page_event_survey(params[:event], params[:design], @page)
    @survey = Survey.new(json: @json)
    if @json.present?
      @section = Section.new(json: @json.dig("section")) if @json.dig("section").present?
      @variable = Variable.new(json: @json.dig("variable")) if @json.dig("variable").present?
    end
    redirect_to survey_complete_path(params[:event], params[:design]) if @json.blank?
  end

  # GET /survey/:event/:design/:resume
  def resume
    @json = current_user.resume_event_survey(params[:event], params[:design])
    @survey = Survey.new(json: @json)
    if @json.blank?
      redirect_to survey_complete_path(params[:event], params[:design])
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
    (@json, @status) = current_user.submit_response_event_survey(params[:event], params[:design], @page, value)
    if @status.is_a?(Net::HTTPOK)
      redirect_to survey_page_path(params[:event], params[:design], @page + 1)
    elsif @json
      @section = Section.new(json: @json.dig("section")) if @json.dig("section").present?
      @variable = Variable.new(json: @json.dig("variable")) if @json.dig("variable").present?
      render :page
    else
      redirect_to survey_page_path(params[:event], params[:design], @page)
    end
  end

  # GET /survey/:event/:design/complete
  def complete
    redirect_to dashboard_path
  end

  private

  def find_page
    @page = [params[:page].to_i, 1].max
  end
end
