require 'rails_helper'

RSpec.describe 'Storefront::Sessions', type: :request do
  let(:password) { 'Password1!' }
  let(:user) { Spree::User.create!(email: 'viewer@example.com', password:, password_confirmation: password) }
  let(:gym) { Gym.create!(name: 'City Gym', slug: 'city-gym') }
  let(:class_type) { ClassType.create!(gym:, name: 'Pilates') }
  let!(:membership) do
    Membership.create!(
      user:,
      gym:,
      plan_type: :credit,
      credits_per_week: 3,
      rollover_limit: 9,
      starts_on: Date.current.beginning_of_month
    )
  end
  let(:session_record) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: 2.days.from_now.change(hour: 9, min: 30),
      capacity: 6,
      trainer_name: 'Coach Kim'
    )
  end

  before do
    CreditLedger.create!(user:, gym:, amount: 3, reason: :monthly_grant)
    sign_in user, scope: :user
  end

  describe 'GET /sessions/:id' do
    it 'shows the booking button when not yet booked' do
      get storefront_session_path(session_record, gym_slug: gym.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Boek')
      expect(response.body).not_to include('Annuleer')
    end

    it 'shows the cancel button when already booked' do
      BookingManager.new(session: session_record, user:).book!

      get storefront_session_path(session_record, gym_slug: gym.slug)

      expect(response.body).to include('Annuleer')
    end
  end
end
