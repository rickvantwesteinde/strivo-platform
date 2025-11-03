# frozen_string_literal: true

require 'date'

namespace :credits do
  desc 'Grant monthly credits for memberships active in the target month (YYYY-MM)'
  task :grant_month, [:month] => :environment do |_t, args|
    month = args[:month].present? ? Date.strptime(args[:month], '%Y-%m') : Date.current
    memberships = Membership.active_during_month(month)

    results = MonthlyCreditGrantService.grant_month!(memberships, month:)

    granted = results.reject(&:skipped?).sum(&:granted_amount)
    expired = results.reject(&:skipped?).sum(&:expired_amount)
    skipped = results.select(&:skipped?).count

    puts "Processed #{results.size} memberships"
    puts "Granted credits: #{granted}"
    puts "Expired rollover: #{expired}"
    puts "Skipped memberships: #{skipped}"
  end
end
