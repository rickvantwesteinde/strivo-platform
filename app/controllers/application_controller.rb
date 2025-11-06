# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper :navigation   # => credits_balance_badge overal beschikbaar

  # ---- Fallback only if you don't already have current_gym somewhere else ----
  helper_method :current_gym

  private

  def current_gym
    # Als je al een gym-scope hebt, gebruik die. Dit is een simpele fallback:
    @current_gym ||= Gym.first
  end
end