# frozen_string_literal: true

# Displays profile pages.
class ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :check_consented

  layout "full_page"

  # GET /profile/complete
  def complete
    render layout: "full_page_no_header_no_footer"
  end

  # PATCH /profile/complete
  def complete_submit
    dob = parse_date_of_birth
    if current_user.update_profile!(dob, params[:address])
      redirect_to profile_signature_path
    else
      @address_error = params[:address].blank?
      @date_error = \
        if dob.blank?
          "Please enter a valid date."
        elsif !current_user.at_least_18?(dob)
          "You must be at least 18 years old to join the study."
        end
      render :complete, layout: "full_page_no_header_no_footer"
    end
  end

  # GET /profile/signature
  def signature
    render layout: "full_page_no_header_no_footer"
  end

  # POST /profile/signature
  def signature_submit
    if current_user.save_signature!(params[:data_uri])
      redirect_to dashboard_path, notice: "Welcome to the study! Check your email to complete registration."
    else
      render :signature, layout: "full_page_no_header_no_footer"
    end
  end

  # # GET /profile/dob
  # def dob
  # end

  # PATCH /profile/dob
  def change_dob
    dob = parse_date_of_birth
    if current_user.update_date_of_birth!(dob)
      redirect_to settings_path, notice: "Date of birth updated successfully."
    else
      @date_error = dob.blank? ? "Please enter a valid date." : "You must be at least 18 years old to join the study."
      render :dob
    end
  end

  # # GET /profile/address
  # def dob
  # end

  # PATCH /profile/address
  def change_address
    if current_user.update_address!(params[:address])
      redirect_to settings_path, notice: "Address updated successfully."
    else
      @address_error = true
      render :address
    end
  end

  private

  def parse_date_of_birth
    date_string = "#{params[:date_of_birth][:year]}-#{params[:date_of_birth][:month]}-#{params[:date_of_birth][:day]}"
    Date.strptime(date_string, "%Y-%m-%d")
  rescue
    nil
  end
end
