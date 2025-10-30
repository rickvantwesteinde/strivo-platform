# spec/requests/storefront/bookings_spec.rb
require 'rails_helper'

RSpec.describe 'Storefront::Bookings', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'Password1!' }
  let(:user) { Spree::User.create!(email: 'user@example.com', password:, password_confirmation: password) }
  let(:gym) { Gym.create!(name: 'Strivo HQ', slug: 'strivo-hq') }
  let(:policy) { Policy.create!(gym: gym, cancel_cutoff_hours: 6, rollover_limit: 2, max_active_daily_bookings: 1) }
  let(:plan) { SubscriptionPlan.create!(gym: gym, name: 'Basic', per_week: 3) }
  let(:subscription) { Subscription.create!(gym: gym, user: user, subscription_plan: plan, starts_on: 1.month.ago, status: :active) }
  let(:class_type) { ClassType.create!(gym: gym, name: 'HIIT', default_capacity: 8) }
  let(:session_record) do
    Session.create!(
      class_type: class_type,
      trainer: Trainer.create!(gym: gym, user: Spree::User.create!(email: 'trainer@example.com', password: password)),
      starts_at: 3.days.from_now.change(hour: 10),
      capacity: 8
    )
  end

  before do
    policy # create
    CreditLedger.create!(user: user, gym: gym, amount: 5, reason: :monthly_grant)
  end

  describe 'POST /bookings' do
    it 'requires authentication' do
      post storefront_bookings_path, params: { session_id: session_record.id }
      expect(response).to redirect_to(spree_login_path)
    end

    it 'creates a booking and consumes a credit' do
      sign_in user
      expect {
        post storefront_bookings_path, params: { session_id: session_record.id }
      }.to change(Booking, :count).by(1)
        .and change { CreditLedger.where(reason: :booking_charge).count }.by(1)

      expect(response).to redirect_to(storefront_session_path(session_record))
      expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(4)
    end
  end

  describe 'DELETE /bookings/:id' do
    let(:booking) { BookingManager.new(user: user, session: session_record).book.booking }

    before { sign_in user }

    it 'refunds a credit when canceling before the cutoff' do
      travel_to(session_record.starts_at - 5.hours) do
        expect {
          delete storefront_booking_path(booking)
        }.to change { CreditLedger.where(reason: :booking_refund).count }.by(1)
      end
      expect(booking.reload.status_canceled?).to be true
      expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(5)
    end

    it 'does not refund after the cutoff' do
      travel_to(session_record.cutoff_time + 30.minutes) do
        expect {
          delete storefront_booking_path(booking)
        }.not_to change { CreditLedger.where(reason: :booking_refund).count }
      end
      expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(4)
    end
  end
end
