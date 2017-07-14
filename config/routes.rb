# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

  scope module: :external do
    get :landing
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :version
  end

  scope module: :internal do
    get :consent
    post :consent, action: :submit_consent
    get :dashboard
    get :signature
    get :survey
    get :thank_you, path: "thank-you"
  end

  devise_for :users,
             controllers: {
               confirmations: "confirmations",
               passwords: "passwords",
               registrations: "registrations",
               sessions: "sessions",
               unlocks: "unlocks"
             },
             path_names: { sign_up: "join", sign_in: "login" },
             path: ""
end
