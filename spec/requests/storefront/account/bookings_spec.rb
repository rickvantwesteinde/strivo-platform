require 'rails_helper'

RSpec.describe 'Storefront::Account::Bookings', type: :request do
  let(:password) { 'Password1!' }
  let(:user) { Spree::User.create!(email: 'account@example.com', password:, password_confirmation: password) }
  let(:gym) { Gym.create!(name: 'Account Gym', slug: 'account-gym') }
  let(:other_gym) { Gym.create!(name: 'Other Gym', slug: 'other-gym') }
  let(:class_type) { ClassType.create!(gym:, name: 'Strength') }
  let(:other_class_type) { ClassType.create!(gym: other_gym, name: 'Yoga') }
  let!(:credit_membership) do
    Membership.create!(
      user:,
      gym:,
      plan_type: :credit,
      credits_per_week: 4,
      rollover_limit: 12,
      starts_on: Date.current.beginning_of_month
    )
  end
  let!(:unlimited_membership) do
    Membership.create!(
      user:,
      gym: other_gym,
      plan_type: :unlimited,
      daily_soft_cap: 3,
      starts_on: Date.current.beginning_of_month
    )
  end
  let!(:session_one) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: 1.day.from_now.change(hour: 11),
      capacity: 8,
      trainer_name: 'Coach Credit'
    )
  end
  let!(:session_two) do
    Session.create!(
      gym: other_gym,
      class_type: other_class_type,
      starts_at: 1.day.from_now.change(hour: 15),
      capacity: 8,
      trainer_name: 'Coach Unlimited'
    )
  end

  before do
    CreditLedger.create!(user:, gym:, amount: 5, reason: :monthly_grant)
    Booking.create!(user:, session: session_one, status: :confirmed)
    Booking.create!(user:, session: session_two, status: :confirmed)
    sign_in user
  end

  it 'shows credit balance for the selected gym' do
    get storefront_account_bookings_path, params: { gym_slug: gym.slug }

    expect(response.body).to include('Beschikbare credits:')
    expect(response.body).to include('5')
    expect(response.body).to include('Coach Credit')
    expect(response.body).not_to include('Coach Unlimited')
  end

  it 'shows unlimited plan details for the other gym' do
    get storefront_account_bookings_path, params: { gym_slug: other_gym.slug }

    expect(response.body).to include('Plan:')
    expect(response.body).to include('Onbeperkt')
    expect(response.body).to include('Coach Unlimited')
    expect(response.body).not_to include('Beschikbare credits:')
  end
end
