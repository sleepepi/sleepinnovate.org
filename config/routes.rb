# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

  scope module: :admin do
    get "admin" => "admin#admin"
  end

  namespace :admin do
    resources :users do
      member do
        post :assign_subject, path: "assign-subject"
        post :unrevoke
      end
    end
  end

  scope module: :external do
    get :about
    get :print_consent, path: "consent.pdf"
    get :consent
    get :contact
    get :landing
    get :landing2
    get :settings_password_reset, path: "settings/password/reset"
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :version
  end

  scope module: :internal do
    post :consent, action: :submit_consent
    delete :consent, action: :revoke_consent
    get :awards
    get :dashboard
    get :dashboard2
    get :signature
    get :survey
    get :test_my_brain, path: "test-my-brain"
    get :biobank
    get :whats_next, path: "whats-next"
    get :thank_you, path: "thank-you"
    post :start_survey, path: "start-survey"
    get :show_survey, path: "show-survey"
    post :test_my_brain_start, path: "test-my-brain/start"
    post :test_my_brain_complete, path: "test-my-brain/complete"
    post :biobank_start, path: "biobank/start"
    post :biobank_complete, path: "biobank/complete"
  end

  scope module: :settings do
    get :settings
  end

  namespace :settings do
    # root to: "settings#index"
    get :consents
    get :leave_study, path: "leave-study"
    get :password
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
