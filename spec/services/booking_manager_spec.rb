require 'rails_helper'

RSpec.describe BookingManager do
  let(:gym) { create(:gym) }
  let(:plan) { create(:subscription_plan, gym:, per_week: 2, unlimited: false) }
  let(:user) { create(:spree_user) }
  let!(:subscription) { create(:subscription, user:, plan:, gym:, starts_on: Date.current.beginning_of_month) }
  let(:class_type) { create(:class_type, gym:) }
  let(:trainer) { create(:trainer, gym:) }
  let(:session_record) { create(:session, class_type:, trainer:, starts_at: 1.day.from_now.change(min: 0)) }

  before do
    CreditLedger.create!(gym:, user:, amount: 2, reason: :monthly_grant, metadata: { month: Date.current.beginning_of_month.iso8601 })
  end

  it "refunds a credit when canceling before the cutoff" do
    booking = described_class.new(user:, session: session_record).book.booking

    expect do
      described_class.new(user:, session: session_record).cancel(
        booking:,
        canceled_at: session_record.starts_at - 7.hours
      )
    end.to change { CreditLedger.where(user:, gym:, reason: :booking_refund).count }.by(1)

    expect(CreditLedger.balance_for(user:, gym:)).to eq(2)
  end

  it "does not refund when canceling inside the cutoff window" do
    booking = described_class.new(user:, session: session_record).book.booking

    expect do
      described_class.new(user:, session: session_record).cancel(
        booking:,
        canceled_at: session_record.starts_at - 2.hours
      )
    end.not_to change { CreditLedger.where(user:, gym:, reason: :booking_refund).count }

    expect(CreditLedger.balance_for(user:, gym:)).to eq(1)
  end
end
