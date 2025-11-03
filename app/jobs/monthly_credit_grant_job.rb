# frozen_string_literal: true

class MonthlyCreditGrantJob < ApplicationJob
  queue_as :default

  def perform(month = Date.current)
    month = month.to_date.beginning_of_month
    memberships = Membership.active_during_month(month)
    MonthlyCreditGrantService.grant_month!(memberships, month:)
  end
end
