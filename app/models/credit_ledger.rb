# app/models/credit_ledger.rb
class CreditLedger < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :booking, optional: true

  # Redenen waarom credits veranderen
  enum :reason, %i[
    monthly_grant
    booking_charge
    booking_refund
    rollover_expiry
    manual_adjustment
  ], prefix: true

  validates :amount, presence: true

  # Scopes
  scope :for_user, ->(user) { where(user:) }
  scope :for_gym,  ->(gym)  { where(gym:) }

  # ---- Class methods ----
  # Totaalsaldo per gebruiker/gym
  def self.balance_for(user:, gym:)
    for_user(user).for_gym(gym).sum(:amount)
  end

  # Controle of er deze maand al credits zijn toegekend
  def self.monthly_grant_exists?(subscription:, month:)
    month_string = month.iso8601
    for_user(subscription.user)
      .for_gym(subscription.gym)
      .where(reason: reasons[:monthly_grant])
      .where("metadata ->> 'month' = ?", month_string)
      .exists?
  end
end
