# frozen_string_literal: true

# Displays the admin dashboard.
class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "full_page"

  # # GET /admin
  # def admin
  # end

  protected

  def check_admin
    redirect_to dashboard_path unless current_user.admin?
  end
end
