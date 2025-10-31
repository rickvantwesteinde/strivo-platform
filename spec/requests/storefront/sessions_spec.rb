# spec/requests/storefront/sessions_spec.rb
require 'rails_helper'
include_context "with gym context"

RSpec.describe 'Storefront::Sessions', type: :request do
  let(:password) { 'Password1!' }
  let(:user) { Spree::User.create!(email: 'viewer@example.com', password:, password_confirmation: password) }
  let(:gym) { Gym.create!(name: 'City Gym', slug: 'city-gym') }
  let(:class_type) { ClassType.create!(gym: gym, name: 'Pilates', default_capacity: 6) }
  let(:trainer) { Trainer.create!(gym: gym, user: Spree::User.create!(email: 't@example.com', password: password)) }
  let(:session_record) do
    Session.create!(
      class_type: class_type,
      trainer: trainer,
      starts_at: 2.days.from_now.change(hour: 9, min: 30),
      capacity: 6
    )
  end

  before do
    CreditLedger.create!(user: user, gym: gym, amount: 3, reason: :monthly_grant)
    sign_in user
  end

  describe 'GET /sessions/:id' do
    it 'shows the booking button when not yet booked' do
      get storefront_session_path(session_record)
      expect(response.body).to include('Boek')
      expect(response.body).not_to include('Annuleer')
    end

    it 'shows the cancel button when already booked' do
      BookingManager.new(user: user, session: session_record).book
      get storefront_session_path(session_record)
      expect(response.body).to include('Annuleer')
    end
  end
end
