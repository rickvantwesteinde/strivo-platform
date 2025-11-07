# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # -------------------------
  # App-level account routes
  # -------------------------
  namespace :account do
    resources :credits, only: [:index]
    get :pane, to: "pane#show" # => account_pane_path
  end

  # -------------------------
  # Extra route definitions
  # -------------------------
  draw :credits

  # -------------------------
  # Spree routes (auth)
  # -------------------------
  Spree::Core::Engine.add_routes do
    # Storefront user auth
    scope "(:locale)", locale: /#{Spree.available_locales.join("|")}/, defaults: { locale: nil } do
      devise_for(
        Spree.user_class.model_name.singular_route_key,
        class_name: Spree.user_class.to_s,
        path: :user,
        controllers: {
          sessions:      "spree/user_sessions",
          passwords:     "spree/user_passwords",
          registrations: "spree/user_registrations"
        },
        router_name: :spree
      )
    end

    # Admin auth
    devise_for(
      Spree.admin_user_class.model_name.singular_route_key,
      class_name: Spree.admin_user_class.to_s,
      controllers: {
        sessions:  "spree/admin/user_sessions",
        passwords: "spree/admin/user_passwords"
      },
      skip: :registrations,
      path: :admin_user,
      router_name: :spree
    )
  end

  # -------------------------
  # Strivo storefront routes
  # -------------------------
  namespace :storefront, path: "", module: :storefront do
    resources :classes,  only: [:index]
    resources :sessions, only: [:show]
    resources :bookings, only: [:create, :destroy]

    namespace :account, module: :account do
      resources :bookings, only: [:index]
    end

    # <<-- HIER staat ‘club’ correct genamespace’d
    get "club", to: "club#index", as: :club
  end

  # -------------------------
  # Mount engines & dashboards
  # -------------------------
  mount Spree::Core::Engine,    at: "/"
  mount Strivo::Admin::Engine,  at: "/admin/strivo"
  mount Sidekiq::Web,           at: "/sidekiq"

  # -------------------------
  # Misc
  # -------------------------
  get "up" => "rails/health#show", as: :rails_health_check
  root "spree/home#index"
end