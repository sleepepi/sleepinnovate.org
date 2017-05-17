# frozen_string_literal: true

# Displays public pages.
class ExternalController < ApplicationController
  # # GET /landing
  # def landing
  # end

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
