class Membership < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :gym

  enum :plan_type, { credit: 0, unlimited: 1 }, default: :credit

  validates :starts_on, presence: true
  validates :credits_per_week, presence: true, numericality: { greater_than: 0 }, if: :credit?
  validates :daily_soft_cap, presence: true, numericality: { greater_than: 0 }, if: :unlimited?
  validates :rollover_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :for_user_and_gym, ->(user, gym) { where(user:, gym:) }
  scope :active_on, lambda { |date|
    where('starts_on <= ?', date)
      .where('ends_on IS NULL OR ends_on >= ?', date)
  }
  scope :active_during_month, lambda { |date|
    month_start = date.beginning_of_month
    month_end = date.end_of_month

    where('starts_on <= ?', month_end)
      .where('ends_on IS NULL OR ends_on >= ?', month_start)
  }

  def active_on?(date)
    starts_on <= date && (ends_on.nil? || ends_on >= date)
  end

  def month_coverage(date)
    month_start = date.beginning_of_month
    month_end = date.end_of_month

    effective_start = [starts_on, month_start].max
    effective_end = [ends_on || month_end, month_end].min

    return 0 if effective_end < month_start || effective_start > month_end

    (effective_end - effective_start + 1).to_i
  end
end
