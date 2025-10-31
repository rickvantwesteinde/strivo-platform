require 'rails_helper'

RSpec.describe 'Storefront::Bookings', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'Password1!' }
  let(:user) { create(:spree_user, password:, password_confirmation: password) }
  let(:gym) { create(:gym, name: 'Strivo HQ', slug: 'strivo-hq') }
  let(:class_type) { create(:class_type, gym:) }
  let(:trainer) { create(:trainer, gym:) }
  let(:session_record) do
    create(
      :session,
      class_type:,
      trainer:,
      starts_at: 3.days.from_now.change(hour: 10, min: 0),
      duration_minutes: class_type.default_duration_minutes
    )
  end

  before do
    CreditLedger.create!(user:, gym:, amount: 5, reason: :monthly_grant)
  end

  describe 'POST /bookings' do
    it 'requires authentication' do
      post storefront_bookings_path, params: { session_id: session_record.id }

      expect(response).to redirect_to(spree_login_path)
    end

    it 'creates a booking and consumes a credit' do
      sign_in user

      expect do
        post storefront_bookings_path, params: { session_id: session_record.id }
      end.to change(Booking, :count).by(1)
        .and change { CreditLedger.where(reason: :booking_charge).count }.by(1)

      expect(response).to redirect_to(storefront_session_path(session_record))
      expect(flash[:notice]).to be_present
      expect(CreditLedger.balance_for(user:, gym:)).to eq(4)
    end
  end

  describe 'DELETE /bookings/:id' do
    before { sign_in user }

    it 'refunds a credit when canceling before the cutoff' do
      booking = BookingManager.new(session: session_record, user:).book!

      travel_to(session_record.starts_at - 5.hours) do
        expect do
          delete storefront_booking_path(booking)
        end.to change { CreditLedger.where(reason: :booking_refund).count }.by(1)
      end

      expect(response).to redirect_to(storefront_session_path(session_record))
      expect(flash[:notice]).to be_present
      expect(booking.reload).to be_canceled
      expect(CreditLedger.balance_for(user:, gym:)).to eq(5)
    end

    it 'does not refund after the cutoff' do
      booking = BookingManager.new(session: session_record, user:).book!

      cutoff_time = session_record.starts_at - class_type.default_cancellation_cutoff_hours.hours
      travel_to(cutoff_time + 30.minutes) do
        expect do
          delete storefront_booking_path(booking)
        end.not_to change { CreditLedger.where(reason: :booking_refund).count }
      end

      expect(response).to redirect_to(storefront_session_path(session_record))
      expect(booking.reload).to be_canceled
      expect(CreditLedger.balance_for(user:, gym:)).to eq(4)
    end
  end
end
