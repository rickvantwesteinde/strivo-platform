# frozen_string_literal: true

class Storefront::DashboardController < Storefront::BaseController
  def index
    @sessions_today = current_gym.sessions
                                 .where("DATE(starts_at) = ?", Date.current)
                                 .includes(:class_type, :trainer, :bookings)
                                 .order(:starts_at)
  end
end
