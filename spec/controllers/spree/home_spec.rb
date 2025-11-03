# spec/requests/spree/home_spec.rb
require 'rails_helper'

RSpec.describe 'Spree home', type: :request do
  it 'renders the home page' do
    get spree.root_path
    expect(response).to be_successful
    # Optioneel, als je echt op de template wilt asserten:
    # expect(response).to render_template('spree/home/index')
  end
end
