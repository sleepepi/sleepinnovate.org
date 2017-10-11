# frozen_string_literal: true

# Displays the admin dashboard.
class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "full_page"

  # # GET /admin
  # def admin
  # end

  # # GET /admin/consented
  # def consented
  # end

  # GET /admin/consented/:clinic
  def consented_clinic
    @clinic = params[:clinic].downcase
    render :consented
  end

  protected

  def check_admin
    redirect_to dashboard_path unless current_user.admin?
  end
end
