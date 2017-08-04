# frozen_string_literal: true

# Displays survey pages.
class SurveyController < ApplicationController
  before_action :authenticate_user!
  before_action :find_page, only: [:page, :submit_page]

  layout "full_page"

  # GET /survey/:event/:design/start
  def start
    @json = current_user.start_event_survey(params[:event], params[:design])
  end

  # GET /survey/:event/:design/:page
  def page
    @json = current_user.page_event_survey(params[:event], params[:design], @page)
    redirect_to survey_complete_path(params[:event], params[:design]) if @json.blank?
  end

  # PATCH /survey/:event/:design/:page
  def submit_page
    (@json, @status) = current_user.submit_response_event_survey(params[:event], params[:design], @page, params[:response])
    if @status.is_a?(Net::HTTPOK)
      redirect_to survey_page_path(params[:event], params[:design], @page + 1)
    else
      render :page
    end
  end

  # GET /survey/:event/:design/complete
  def complete
    # @json = current_user.complete_event_survey(params[:event], params[:design])
  end

  private

  def find_page
    @page = [params[:page].to_i, 1].max
  end
end
