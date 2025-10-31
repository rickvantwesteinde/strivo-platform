# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlyCreditGrant do
  include_context 'with gym context'

  let(:plan) { create(:subscription_plan, gym: gym, per_week: 3, unlimited: false) }
  let(:user) { create(:spree_user) }
  let!(:subscription) do
    create(:subscription, user: user, subscription_plan: plan, gym: gym,
                          starts_on: Date.new(2024, 1, 1))
  end

  it 'grants monthly credits using the half-up formula and enforces rollover limit' do
    # Grant credits for March
    previous_month = Date.new(2024, 3, 1)
    CreditLedger.create!(
      gym: gym,
      user: user,
      amount: 5,
      reason: :monthly_grant,
      metadata: { month: previous_month.iso8601 }
    )

    # Grant credits for April (31 days)
    described_class.new(subscription: subscription, as_of: Date.new(2024, 4, 1)).call

    ledgers = CreditLedger.where(user: user, gym: gym).order(:created_at)
    expect(ledgers.pluck(:reason)).to include('rollover_expiry', 'monthly_grant')

    # Rollover limit is 2, so excess 3 credits should be removed
    expect(ledgers.where(reason: :rollover_expiry).sum(:amount)).to eq(-3)
    
    # April has 30 days: (3 * (30 / 7.0)).round(half: :up) = (3 * 4.2857).round(half: :up) = 13
    april_grant = ledgers.where(reason: :monthly_grant).order(:created_at).last.amount
    expect(april_grant).to eq(13)
    
    # Total balance: 5 (March) - 3 (rollover) + 13 (April) = 15
    expect(CreditLedger.balance_for(user: user, gym: gym)).to eq(15)
  end

  it 'does not grant twice in the same month' do
    described_class.new(subscription: subscription, as_of: Date.new(2024, 4, 1)).call

    expect do
      described_class.new(subscription: subscription, as_of: Date.new(2024, 4, 15)).call
    end.not_to change { CreditLedger.where(user: user, gym: gym).count }
  end
end
