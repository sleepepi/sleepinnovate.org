# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

  scope module: :external do
    get :about
    get :print_consent, path: "consent.pdf"
    get :consent
    get :contact
    get :landing
    get :landing2
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :version
  end

  scope module: :internal do
    post :consent, action: :submit_consent
    delete :consent, action: :revoke_consent
    get :awards
    get :consents
    get :dashboard
    get :dashboard2
    get :signature
    get :survey
    get :test_my_brain, path: "test-my-brain"
    get :biobank
    get :thank_you, path: "thank-you"
    post :start_survey, path: "start-survey"
    get :show_survey, path: "show-survey"
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
