# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

  scope module: :admin do
    get "admin" => "admin#admin"

    namespace :admin do
      get :consented
      get :consented_clinic, path: "consented/:clinic"
    end
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
    get :pledge
    get :print_consent, path: "consent.pdf"
    get :consent
    get :enrollment_start, path: "enrollment/start", to: redirect("consent")
    post :enrollment_start, path: "enrollment/start"
    get :enrollment_exit, path: "enrollment/exit"
    get :enrollment_consent, path: "enrollment/consent", to: redirect("consent")
    post :enrollment_consent, path: "enrollment/consent"
    get :contact
    get :clinic, path: "clinic(/:clinic)"
    get :landing
    get :settings_password_reset, path: "settings/password/reset"
    get :sitemap_xml, path: "sitemap.xml.gz"
    get :version
  end

  scope module: :internal do
    post :consent, action: :submit_consent
    delete :consent, action: :revoke_consent
    get :awards
    get :dashboard
    get :test_my_brain, path: "test-my-brain"
    get :parking, path: "parking-voucher"
    get :whats_next, path: "whats-next"
    post :test_my_brain_start, path: "test-my-brain/start"
    post :biobank_start, path: "biobank/start"
    post :biobank_complete, path: "biobank/complete"
    get :surveys
    get :leave_study, path: "leave-study"
    post :submit_leave_study, path: "leave-study"
    get :returning_from, path: "returning-from/:external/:subject_code"
  end

  scope module: :profile do
    get :profile, to: redirect("settings")
  end

  namespace :profile do
    get :address
    patch :change_address, path: "address"
    get :dob
    patch :change_dob, path: "dob"
    get :complete
    patch :complete_submit, path: "complete"
    get :signature
    patch :signature_submit, path: "signature"
  end

  scope module: :settings do
    get :settings
  end

  namespace :settings do
    # root to: "settings#index"
    get :consents
    get :password
    patch :change_password, path: "password"
    get :email
    patch :change_email, path: "email"
  end

  namespace :survey do
    get :start, path: ":event/:design/start"
    get :resume, path: ":event/:design/resume"
    get :complete, path: ":event/:design/complete"
    get :page, path: ":event/:design/:page"
    patch :submit_page, path: ":event/:design/:page"
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
