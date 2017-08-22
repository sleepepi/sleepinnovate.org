# frozen_string_literal: true

# Displays public pages.
class ExternalController < ApplicationController
  layout "full_page"

  # # GET /about
  # def about
  # end

  # GET /consent
  def consent
    render layout: "full_page_no_header_no_footer" if current_user && current_user.first_login?
  end

  # GET /consent.pdf
  def print_consent
    pdf_file = Rails.root.join(User.generate_printed_pdf!(current_user))
    if File.exist?(pdf_file)
      send_file(pdf_file, filename: "SleepINNOVATEConsentForm.pdf", type: "application/pdf", disposition: "inline")
    else
      redirect_to consent_path, alert: "Unable to generate PDF at this time."
    end
  end

  # # GET /contact
  # def contact
  # end

  # GET /landing
  def landing
    redirect_to dashboard_path if current_user
  end

  # GET /pledge
  def pledge
    render layout: "full_page_no_header_no_footer"
  end

  # GET /settings/password/reset
  def settings_password_reset
    sign_out @user if current_user
    redirect_to edit_user_password_path(reset_password_token: params[:reset_password_token])
  end

  # GET /sitemap.xml.gz
  def sitemap_xml
    sitemap_xml = File.join(CarrierWave::Uploader::Base.root, "sitemaps", "sitemap.xml.gz")
    if File.exist?(sitemap_xml)
      send_file sitemap_xml
    else
      head :ok
    end
  end

  # # GET /version
  # # GET /version.json
  # def version
  # end
end
