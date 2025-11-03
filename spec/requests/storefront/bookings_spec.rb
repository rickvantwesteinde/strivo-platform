require 'rails_helper'

RSpec.describe 'Storefront::Bookings', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'Password1!' }
  let(:user) { Spree::User.create!(email: 'user@example.com', password:, password_confirmation: password) }
  let(:gym) { Gym.create!(name: 'Strivo HQ', slug: 'strivo-hq') }
  let(:class_type) { ClassType.create!(gym:, name: 'HIIT') }
  let!(:membership) do
    Membership.create!(
      user:,
      gym:,
      plan_type: :credit,
      credits_per_week: 4,
      rollover_limit: 12,
      starts_on: Date.current.beginning_of_month
    )
  end
  let(:session_record) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: 3.days.from_now.change(hour: 10, min: 0),
      capacity: 8,
      trainer_name: 'Trainer Tom'
    )
  end

  before do
    CreditLedger.create!(user:, gym:, amount: 5, reason: :monthly_grant)
  end

  describe 'POST /bookings' do
    it 'requires authentication' do
      post storefront_bookings_path, params: { session_id: session_record.id, gym_slug: gym.slug }

      expect(response).to redirect_to(spree_login_path)
    end

    it 'creates a booking and consumes a credit' do
      sign_in_spree(user)

      expect do
        post storefront_bookings_path, params: { session_id: session_record.id, gym_slug: gym.slug }
      end.to change(Booking, :count).by(1)
        .and change { CreditLedger.where(reason: :booking_charge).count }.by(1)

      expect(response).to redirect_to(storefront_session_path(session_record, gym_slug: gym.slug))
      expect(flash[:notice]).to be_present
      expect(CreditLedger.remaining_for(user:, gym:)).to eq(4)
    end

    it 'rejects booking for a different gym' do
      other_gym = Gym.create!(name: 'Andere Gym', slug: 'andere-gym')
      other_class_type = ClassType.create!(gym: other_gym, name: 'Spin')
      other_session = Session.create!(
        gym: other_gym,
        class_type: other_class_type,
        starts_at: 2.days.from_now.change(hour: 8, min: 0),
        capacity: 5,
        trainer_name: 'Trainer Tess'
      )

      sign_in_spree(user)

      expect do
        post storefront_bookings_path, params: { session_id: other_session.id, gym_slug: gym.slug }
      end.not_to change(Booking, :count)

      expect(response).to redirect_to(storefront_session_path(other_session, gym_slug: gym.slug))
      expect(flash[:alert]).to eq('Geen actief lidmaatschap voor deze locatie.')
    end
  end

  describe 'DELETE /bookings/:id' do
    before { sign_in_spree(user) }

    it 'refunds a credit when canceling before the cutoff' do
      booking = BookingManager.new(session: session_record, user:).book!

      travel_to(session_record.starts_at - 5.hours) do
        expect do
          delete storefront_booking_path(booking, gym_slug: gym.slug)
        end.to change { CreditLedger.where(reason: :booking_refund).count }.by(1)
      end

      expect(response).to redirect_to(storefront_session_path(session_record, gym_slug: gym.slug))
      expect(flash[:notice]).to be_present
      expect(booking.reload).to be_status_canceled
      expect(CreditLedger.remaining_for(user:, gym:)).to eq(5)
    end

    it 'does not refund after the cutoff' do
      booking = BookingManager.new(session: session_record, user:).book!

      travel_to(session_record.cutoff_time + 30.minutes) do
        expect do
          delete storefront_booking_path(booking, gym_slug: gym.slug)
        end.not_to change { CreditLedger.where(reason: :booking_refund).count }
      end

      expect(response).to redirect_to(storefront_session_path(session_record, gym_slug: gym.slug))
      expect(booking.reload).to be_status_canceled
      expect(CreditLedger.remaining_for(user:, gym:)).to eq(4)
    end
  end

  describe 'unlimited memberships' do
    before { membership.update!(ends_on: Date.current.beginning_of_month - 1.day) }

    let!(:unlimited_membership) do
      Membership.create!(
        user:,
        gym:,
        plan_type: :unlimited,
        daily_soft_cap: 2,
        starts_on: Date.current.beginning_of_month
      )
    end

    let!(:other_session) do
      Session.create!(
        gym:,
        class_type:,
        starts_at: 3.days.from_now.change(hour: 12, min: 0),
        capacity: 10,
        trainer_name: 'Trainer Uli'
      )
    end

    it 'allows bookings up to the daily cap without consuming credits' do
      sign_in_spree(user)

      expect do
        post storefront_bookings_path, params: { session_id: session_record.id, gym_slug: gym.slug }
        post storefront_bookings_path, params: { session_id: other_session.id, gym_slug: gym.slug }
      end.to change(Booking, :count).by(2)
        .and change(CreditLedger, :count).by(0)

      expect(flash[:notice]).to be_present
    end

    it 'blocks bookings beyond the daily cap' do
      sign_in_spree(user)

      post storefront_bookings_path, params: { session_id: session_record.id, gym_slug: gym.slug }
      post storefront_bookings_path, params: { session_id: other_session.id, gym_slug: gym.slug }

      third_session = Session.create!(
        gym:,
        class_type:,
        starts_at: session_record.starts_at.change(hour: 18),
        capacity: 6,
        trainer_name: 'Trainer Max'
      )

      expect do
        post storefront_bookings_path, params: { session_id: third_session.id, gym_slug: gym.slug }
      end.not_to change(Booking, :count)

      expect(response).to redirect_to(storefront_session_path(third_session, gym_slug: gym.slug))
      expect(flash[:alert]).to eq('Dagelijkse limiet bereikt.')
    end
  end
end
