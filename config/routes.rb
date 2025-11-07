# config/routes.rb
# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # ============================================================
  # Back-compat redirects
  # ============================================================
  get "/account",         to: redirect("/account/orders"), status: 302
  get "/account/credits", to: redirect("/account/orders"), status: 302

  match "(:locale)/account/store_credits",
        to: redirect("/account/orders"),
        via: :get,
        constraints: { locale: /#{Spree.available_locales.join("|")}/ },
        as: :legacy_store_credits_redirect

  # ============================================================
  # App-level account routes
  # ============================================================
  namespace :account do
    get :pane, to: "pane#show"
  end

  # ============================================================
  # Strivo storefront
  # ============================================================
  namespace :storefront, path: "", module: :storefront do
    resources :classes,  only: [:index]
    resources :sessions, only: [:show]
    resources :bookings, only: [:create, :destroy]

    namespace :account, module: :account do
      resources :bookings, only: [:index]
    end

    get "club", to: "club#index", as: :club
  end

  # ============================================================
  # Spree auth routes (Devise)
  # ============================================================
  Spree::Core::Engine.add_routes do
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

  # ============================================================
  # Engines & misc
  # ============================================================
  mount Spree::Core::Engine,   at: "/"
  mount Strivo::Admin::Engine, at: "/admin/strivo"
  mount Sidekiq::Web,          at: "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check
  root "spree/home#index"
end