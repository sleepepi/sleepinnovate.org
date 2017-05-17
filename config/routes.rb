# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

  scope module: :external do
    get :landing
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :version
  end

  scope module: :internal do
    get :dashboard
    get :survey
    get :thank_you, path: "thank-you"
  end
end
