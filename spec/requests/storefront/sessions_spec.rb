require 'rails_helper'

RSpec.describe 'Storefront::Sessions', type: :request do
  let(:password) { 'Password1!' }
  let(:user) { create(:spree_user, email: 'viewer@example.com', password:, password_confirmation: password) }
  let(:gym) { create(:gym, name: 'City Gym', slug: 'city-gym') }
  let(:class_type) { create(:class_type, gym:, name: 'Pilates') }
  let(:trainer) { create(:trainer, gym:) }
  let(:session_record) do
    create(
      :session,
      class_type:,
      trainer:,
      starts_at: 2.days.from_now.change(hour: 9, min: 30),
      capacity: 6
    )
  end

  before do
    CreditLedger.create!(user:, gym:, amount: 3, reason: :monthly_grant)
    sign_in user
  end

  describe 'GET /sessions/:id' do
    it 'shows the booking button when not yet booked' do
      get storefront_session_path(session_record)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Boek')
      expect(response.body).not_to include('Annuleer')
    end

    it 'shows the cancel button when already booked' do
      BookingManager.new(session: session_record, user:).book!

      get storefront_session_path(session_record)

      expect(response.body).to include('Annuleer')
    end
  end
end
