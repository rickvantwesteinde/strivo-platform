# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Zorg dat Devise/Spree helpers beschikbaar zijn
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    # Enige guard die we willen: redirect ALTIJD naar spree_login_path
    before_action :require_spree_login
    before_action :load_storefront_context

    helper Storefront::CreditsHelper
    helper_method :default_gym, :current_gym, :current_membership, :available_memberships, :spree_current_user

    private

    # Gebruik de spree_current_user helper uit Spree::AuthenticationHelpers

    # Simpele guard die exact naar spree_login_path redirect
    def require_spree_login
      return if spree_current_user.present?

      redirect_to spree_login_path
    end

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end

    def current_gym
      @current_gym
    end

    def current_membership
      @current_membership
    end

    def available_memberships
      return [] if spree_current_user.nil?

      @available_memberships ||= spree_current_user.memberships.includes(:gym).select { |membership| membership.active_on?(Date.current) }
    end

    def load_storefront_context
      @current_gym = resolve_current_gym
      @current_membership = resolve_current_membership
    end

    def resolve_current_gym
      return default_gym if spree_current_user.nil?

      memberships = spree_current_user.memberships.includes(:gym)
      return default_gym if memberships.empty?

      active_memberships = memberships.select { |membership| membership.active_on?(Date.current) }

      if params[:gym_slug].present?
        selected = memberships.find { |membership| membership.gym.slug == params[:gym_slug] }
        return selected.gym if selected
      end

      (active_memberships.presence || memberships).max_by(&:starts_on).gym
    end

    def resolve_current_membership
      return nil if spree_current_user.nil? || current_gym.nil?

      spree_current_user.memberships
                        .for_user_and_gym(spree_current_user, current_gym)
                        .active_on(Date.current)
                        .order(starts_on: :desc)
                        .first
    end
  end
end
