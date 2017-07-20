# frozen_string_literal: true

# Displays public pages.
class ExternalController < ApplicationController
  # GET /about
  def about
    render layout: "full_page"
  end

  # GET /consent
  def consent
    render layout: "full_page"
  end

  # GET /contact
  def contact
    render layout: "full_page"
  end

  # GET /landing
  def landing
    render layout: "full_page"
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

  # GET /version
  # GET /version.json
  def version
    render layout: "full_page"
  end
end
