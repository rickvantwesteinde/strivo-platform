require 'rails_helper'

RSpec.describe MonthlyCreditGrant do
  include_context "with gym context"
  let(:gym) { create(:gym) }
  let(:plan) { create(:subscription_plan, gym:, per_week: 3, unlimited: false) }
  let(:user) { create(:spree_user) }
  let!(:subscription) { create(:subscription, user:, plan:, gym:, starts_on: Date.new(2024, 1, 1)) }

  it "grants monthly credits using the half-up formula and enforces rollover limit" do
    previous_month = Date.new(2024, 3, 1)
    CreditLedger.create!(
      gym:,
      user:,
      amount: 5,
      reason: :monthly_grant,
      metadata: { month: previous_month.iso8601 }
    )

    described_class.new(subscription:, as_of: Date.new(2024, 4, 1)).call

    ledgers = CreditLedger.where(user:, gym:).order(:created_at)
    expect(ledgers.pluck(:reason)).to include("rollover_expiry", "monthly_grant")

    expect(ledgers.where(reason: :rollover_expiry).sum(:amount)).to eq(-3)
    expect(ledgers.where(reason: :monthly_grant).order(:created_at).last.amount).to eq(13)
    expect(CreditLedger.balance_for(user:, gym:)).to eq(15)

    expect do
      described_class.new(subscription:, as_of: Date.new(2024, 4, 15)).call
    end.not_to change { CreditLedger.where(user:, gym:).count }
  end
end
