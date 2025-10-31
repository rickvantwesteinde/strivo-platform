# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Bookings', type: :request do
  include_context 'with gym context'

  let(:plan) { create(:subscription_plan, gym: gym, per_week: 2, unlimited: false) }
  let(:user) { create(:spree_user) }
  let!(:subscription) do
    create(:subscription, user: user, subscription_plan: plan, gym: gym,
                          starts_on: Date.current.beginning_of_month)
  end
  let(:class_type) { create(:class_type, gym: gym) }
  let(:trainer) { create(:trainer, gym: gym) }
  let(:session_time) { Time.zone.local(2024, 1, 1, 18, 0, 0) }
  let(:session_record) do
    create(:session, class_type: class_type, trainer: trainer,
                     starts_at: session_time, duration_minutes: 60, capacity: 5)
  end

  before do
    CreditLedger.create!(
      gym: gym,
      user: user,
      amount: 2,
      reason: :monthly_grant,
      metadata: { month: Date.current.beginning_of_month.iso8601 }
    )
    sign_in user
  end

  describe 'POST /api/v1/bookings' do
    it 'creates a booking when credits are available' do
      travel_to Time.zone.local(2023, 12, 31, 10, 0, 0) do
        post '/api/v1/bookings', params: { booking: { session_id: session_record.id } }, as: :json

        expect(response).to have_http_status(:created)
        payload = JSON.parse(response.body)
        expect(payload['status']).to eq('confirmed')

        booking = Booking.find(payload['id'])
        expect(booking.used_credits).to eq(1)
        expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(1)
      end
    end
  end

  describe 'DELETE /api/v1/bookings/:id' do
    it 'refunds credits when canceled before the cutoff' do
      travel_to Time.zone.local(2023, 12, 31, 10, 0, 0) do
        post '/api/v1/bookings', params: { booking: { session_id: session_record.id } }, as: :json
        booking_id = JSON.parse(response.body)['id']

        delete "/api/v1/bookings/#{booking_id}", as: :json

        expect(response).to have_http_status(:ok)
        expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(2)
        expect(Booking.find(booking_id).status_canceled?).to be true
      end
    end

    it 'does not refund when canceled after the cutoff' do
      near_session_time = session_time - 3.hours

      travel_to near_session_time do
        post '/api/v1/bookings', params: { booking: { session_id: session_record.id } }, as: :json
        booking_id = JSON.parse(response.body)['id']

        delete "/api/v1/bookings/#{booking_id}", as: :json

        expect(response).to have_http_status(:ok)
        expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(1)
        expect(Booking.find(booking_id).status_canceled?).to be true
      end
    end
  end
end
