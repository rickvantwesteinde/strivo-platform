Strivo::Admin::Engine.routes.draw do
  root to: "smoke#index"

  namespace :reports do
    get :utilization, to: 'utilization#index'
  end
end
