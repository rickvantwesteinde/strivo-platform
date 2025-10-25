module Spree
  module UserDecorator
    def self.prepended(base)
      base.has_many :subscriptions, class_name: "::Subscription", foreign_key: :user_id, dependent: :destroy
      base.has_many :bookings, class_name: "::Booking", foreign_key: :user_id, dependent: :destroy
      base.has_many :credit_ledgers, class_name: "::CreditLedger", foreign_key: :user_id, dependent: :destroy
    end
  end
end

Spree::User.prepend Spree::UserDecorator
