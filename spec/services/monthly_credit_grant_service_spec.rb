require 'rails_helper'

RSpec.describe MonthlyCreditGrantService do
  let(:user) { Spree::User.create!(email: 'member@example.com', password: 'Password1!', password_confirmation: 'Password1!') }
  let(:gym) { Gym.create!(name: 'Strivo HQ', slug: 'strivo-hq') }
  let(:target_month) { Date.new(2024, 2, 1) }

  describe '.round_half_up' do
    it 'rounds halves up' do
      expect(described_class.round_half_up(1.4)).to eq(1)
      expect(described_class.round_half_up(1.5)).to eq(2)
      expect(described_class.round_half_up(2.5)).to eq(3)
    end
  end

  context 'with a credit membership active the whole month' do
    let(:membership) do
      Membership.create!(
        user:,
        gym:,
        plan_type: :credit,
        credits_per_week: 3.5,
        rollover_limit: 10,
        starts_on: Date.new(2023, 12, 1)
      )
    end

    it 'grants credits with half-up rounding and enforces rollover limit' do
      CreditLedger.create!(user:, gym:, amount: 9, reason: :monthly_grant)

      result = described_class.new(membership:, month: target_month).call

      expect(result).not_to be_skipped
      expect(result.granted_amount).to eq(15)
      expect(result.expired_amount).to eq(4)

      ledger_entries = CreditLedger.for_user_and_gym(user, gym)
      expect(ledger_entries.where(reason: :monthly_grant).count).to eq(2)
      expect(ledger_entries.sum(:amount)).to eq(20)

      metadata = ledger_entries.order(:created_at).last.metadata
      expect(metadata['month']).to eq('2024-02')
      expect(metadata['granted_amount']).to eq(15)
      expect(metadata['membership_id']).to eq(membership.id)
    end
  end

  context 'with a membership starting mid-month' do
    let(:membership) do
      Membership.create!(
        user:,
        gym:,
        plan_type: :credit,
        credits_per_week: 4,
        rollover_limit: 20,
        starts_on: Date.new(2024, 2, 10)
      )
    end

    it 'prorates based on active days' do
      result = described_class.new(membership:, month: target_month).call

      expect(result).not_to be_skipped
      # 4 credits/week * 20 active days / 7 = 11.428... => 11
      expect(result.granted_amount).to eq(11)
      expect(CreditLedger.remaining_for(user:, gym:)).to eq(11)
    end
  end

  context 'when the membership is not active in the month' do
    let(:membership) do
      Membership.create!(
        user:,
        gym:,
        plan_type: :credit,
        credits_per_week: 3,
        rollover_limit: 10,
        starts_on: Date.new(2024, 3, 1)
      )
    end

    it 'skips processing' do
      result = described_class.new(membership:, month: target_month).call

      expect(result).to be_skipped
      expect(result.reason).to eq('inactive in target month')
      expect(CreditLedger.for_user_and_gym(user, gym)).to be_empty
    end
  end

  context 'with an unlimited membership' do
    let(:membership) do
      Membership.create!(
        user:,
        gym:,
        plan_type: :unlimited,
        credits_per_week: nil,
        daily_soft_cap: 2,
        starts_on: Date.new(2024, 1, 1)
      )
    end

    it 'skips the grant' do
      result = described_class.new(membership:, month: target_month).call

      expect(result).to be_skipped
      expect(result.reason).to eq('non-credit plan')
      expect(CreditLedger.for_user_and_gym(user, gym)).to be_empty
    end
  end
end
