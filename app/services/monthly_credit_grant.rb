# frozen_string_literal: true

class MonthlyCreditGrant
  def initialize(subscription:, as_of: Date.current)
    @subscription = subscription
    @as_of = as_of.to_date
  end

  def call
    return if subscription.unlimited? || !subscription.active_on?(as_of)

    month = as_of.beginning_of_month
    return if CreditLedger.monthly_grant_exists?(subscription: subscription, month: month)

    ActiveRecord::Base.transaction do
      apply_rollover_limit(month)
      grant_monthly_credits(month)
    end
  end

  private

  attr_reader :subscription, :as_of

  def apply_rollover_limit(month)
    policy = subscription.gym.policy or return
    return unless policy.rollover_limit&.positive?

    balance = CreditLedger.balance_for(user: subscription.user, gym: subscription.gym)
    excess = [balance - policy.rollover_limit, 0].max
    return if excess <= 0

    CreditLedger.create!(
      gym: subscription.gym,
      user: subscription.user,
      amount: -excess,
      reason: :rollover_expiry,
      metadata: { month: month.iso8601, subscription_id: subscription.id }
    )
  end

  def grant_monthly_credits(month)
    amount = (subscription.subscription_plan.per_week * (as_of.end_of_month.day / 7.0)).round(half: :up)
    CreditLedger.create!(
      gym: subscription.gym,
      user: subscription.user,
      amount: amount,
      reason: :monthly_grant,
      metadata: { month: month.iso8601, subscription_id: subscription.id }
    )
  end
end
