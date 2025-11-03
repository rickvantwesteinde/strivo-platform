# frozen_string_literal: true

require 'bigdecimal'

class MonthlyCreditGrantService
  Result = Struct.new(
    :membership,
    :granted_amount,
    :expired_amount,
    :skipped?,
    :reason,
    keyword_init: true
  )

  class << self
    def grant_month!(memberships, month: Date.current)
      Array(memberships).map { |membership| new(membership:, month:).call }
    end

    def round_half_up(value)
      BigDecimal(value.to_s).round(0, BigDecimal::ROUND_HALF_UP).to_i
    end
  end

  def initialize(membership:, month: Date.current)
    @membership = membership
    @month = month.to_date.beginning_of_month
  end

  def call
    return skipped_result('non-credit plan') unless membership.credit?
    return skipped_result('inactive in target month') unless coverage_days.positive?
    return skipped_result('already granted') if monthly_grant_exists?

    expired_amount = expire_excess_rollover!
    granted_amount = create_grant!

    Result.new(
      membership:,
      granted_amount:,
      expired_amount:,
      skipped?: false,
      reason: nil
    )
  end

  private

  attr_reader :membership, :month

  def skipped_result(reason)
    Result.new(
      membership:,
      granted_amount: 0,
      expired_amount: 0,
      skipped?: true,
      reason: reason
    )
  end

  def coverage_days
    @coverage_days ||= membership.month_coverage(month)
  end

  def days_in_month
    @days_in_month ||= month.end_of_month.day
  end

  def monthly_grant_exists?
    CreditLedger
      .for_user_and_gym(membership.user, membership.gym)
      .where(reason: :monthly_grant)
      .where("metadata ->> 'month' = ?", month_key)
      .where("metadata ->> 'membership_id' = ?", membership.id.to_s)
      .exists?
  end

  def expire_excess_rollover!
    limit = membership.rollover_limit
    return 0 unless limit.present?

    current_balance = CreditLedger.remaining_for(user: membership.user, gym: membership.gym)
    excess = [current_balance - limit, 0].max
    return 0 if excess.zero?

    CreditLedger.create!(
      user: membership.user,
      gym: membership.gym,
      amount: -excess,
      reason: :rollover_expiry,
      metadata: {
        'month' => month_key,
        'expired_amount' => excess,
        'membership_id' => membership.id
      }
    )

    excess
  end

  def create_grant!
    grant_amount = self.class.round_half_up(grant_quantity)
    return 0 if grant_amount.zero?

    CreditLedger.create!(
      user: membership.user,
      gym: membership.gym,
      amount: grant_amount,
      reason: :monthly_grant,
      metadata: grant_metadata(grant_amount)
    )

    grant_amount
  end

  def grant_quantity
    BigDecimal(membership.credits_per_week.to_s) * BigDecimal(coverage_days.to_s) / BigDecimal('7')
  end

  def grant_metadata(grant_amount)
    {
      'month' => month_key,
      'days_covered' => coverage_days,
      'days_in_month' => days_in_month,
      'credits_per_week' => membership.credits_per_week,
      'granted_amount' => grant_amount,
      'membership_id' => membership.id
    }
  end

  def month_key
    @month_key ||= month.strftime('%Y-%m')
  end
end
