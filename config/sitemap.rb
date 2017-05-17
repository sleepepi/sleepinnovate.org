# frozen_string_literal: true

# To run task
# rails sitemap:refresh:no_ping
# Or production
# rails sitemap:refresh RAILS_ENV=production
# https://www.google.com/webmasters/tools/

require "rubygems"
require "sitemap_generator"

SitemapGenerator.verbose = false
SitemapGenerator::Sitemap.default_host = "https://sleepinnovate.org"
SitemapGenerator::Sitemap.sitemaps_host = ENV["website_url"]
SitemapGenerator::Sitemap.public_path = "carrierwave/sitemaps/"
SitemapGenerator::Sitemap.sitemaps_path = ""
SitemapGenerator::Sitemap.create do
  add "/landing", changefreq: "weekly", priority: 0.5
end
