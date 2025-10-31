# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingManager do
  include_context 'with gym context'

  let(:plan) { create(:subscription_plan, gym: gym, per_week: 2, unlimited: false) }
  let(:user) { create(:spree_user) }
  let!(:subscription) do
    create(:subscription, user: user, subscription_plan: plan, gym: gym,
                          starts_on: Date.current.beginning_of_month)
  end
  let(:class_type) { create(:class_type, gym: gym) }
  let(:trainer) { create(:trainer, gym: gym) }
  let(:session_record) do
    create(:session, class_type: class_type, trainer: trainer,
                     starts_at: 1.day.from_now.change(hour: 10, min: 0))
  end

  before do
    CreditLedger.create!(
      gym: gym,
      user: user,
      amount: 2,
      reason: :monthly_grant,
      metadata: { month: Date.current.beginning_of_month.iso8601 }
    )
  end

  describe '#book' do
    it 'creates a booking when credits are available' do
      result = described_class.new(user: user, session: session_record).book

      expect(result.booking).to be_persisted
      expect(result.booking.status_confirmed?).to be true
      expect(result.waitlisted).to be false
    end

    it 'consumes a credit when booking' do
      expect do
        described_class.new(user: user, session: session_record).book
      end.to change { CreditLedger.balance_for(user: user, gym: gym) }.from(2).to(1)
    end
  end

  describe '#cancel' do
    it 'refunds a credit when canceling before the cutoff' do
      booking = described_class.new(user: user, session: session_record).book.booking

      expect do
        described_class.new(user: user, session: session_record).cancel(
          booking: booking,
          canceled_at: session_record.starts_at - 7.hours
        )
      end.to change { CreditLedger.where(user: user, gym: gym, reason: :booking_refund).count }.by(1)

      expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(2)
    end

    it 'does not refund when canceling inside the cutoff window' do
      booking = described_class.new(user: user, session: session_record).book.booking

      expect do
        described_class.new(user: user, session: session_record).cancel(
          booking: booking,
          canceled_at: session_record.starts_at - 2.hours
        )
      end.not_to change { CreditLedger.where(user: user, gym: gym, reason: :booking_refund).count }

      expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(1)
    end
  end
end
