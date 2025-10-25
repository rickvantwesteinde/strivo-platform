class MonthlyCreditGrant
  def initialize(subscription:, as_of: Date.current)
    @subscription = subscription
    @as_of = as_of.to_date
  end

  def call
    return if subscription.unlimited?
    return unless subscription.active_on?(as_of)

    month = as_of.beginning_of_month
    return if CreditLedger.monthly_grant_exists?(subscription:, month: month)

    ActiveRecord::Base.transaction do
      apply_rollover_limit(month)
      grant_monthly_credits(month)
    end
  end

  private

  attr_reader :subscription, :as_of

  def apply_rollover_limit(month)
    policy = subscription.gym.policy
    return unless policy&.rollover_limit&.positive?

    balance = CreditLedger.balance_for(user: subscription.user, gym: subscription.gym)
    allowed_rollover = [balance, policy.rollover_limit].min
    expired_amount = balance - allowed_rollover
    return if expired_amount <= 0

    CreditLedger.create!(
      gym: subscription.gym,
      user: subscription.user,
      amount: -expired_amount,
      reason: :rollover_expiry,
      metadata: { month: month.iso8601, subscription_id: subscription.id }
    )
  end

  def grant_monthly_credits(month)
    CreditLedger.create!(
      gym: subscription.gym,
      user: subscription.user,
      amount: monthly_credit_amount,
      reason: :monthly_grant,
      metadata: { month: month.iso8601, subscription_id: subscription.id }
    )
  end

  def monthly_credit_amount
    days = as_of.end_of_month.day
    (subscription.plan.per_week * (days / 7.0)).round(half: :up)
  end
end
