# frozen_string_literal: true

namespace :credits do
  desc 'Grant monthly credits to active subscriptions'
  task grant_monthly: :environment do
    as_of = Date.current
    Subscription.current.find_each do |subscription|
      MonthlyCreditGrant.new(subscription: subscription, as_of: as_of).call
    end
  end
end
