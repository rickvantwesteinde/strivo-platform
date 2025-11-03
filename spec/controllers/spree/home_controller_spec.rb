# spec/controllers/spree/home_controller_spec.rb
require 'rails_helper'

RSpec.describe Spree::HomeController, type: :controller do
  # Maak Spree engine-routes beschikbaar voor deze spec.
  # Gebruik Frontend als je spree_frontend als aparte engine hebt,
  # anders Core (werkt in veel setups).
  routes { Spree::Core::Engine.routes }
  # Alternatief (als je Frontend-namespace gebruikt):
  # routes { Spree::Frontend::Engine.routes }

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
