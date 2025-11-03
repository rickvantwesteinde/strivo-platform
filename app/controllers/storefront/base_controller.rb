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
    helper_method :default_gym, :current_spree_user, :current_gym, :current_membership, :available_memberships

    private

    # Eenduidige accessor voor de ingelogde user
    def current_spree_user
      return super if defined?(super)
      return spree_current_user if respond_to?(:spree_current_user, true)
      nil
    end

    # Simpele guard die exact naar spree_login_path redirect
    def require_spree_login
      signed_in =
        (respond_to?(:spree_user_signed_in?, true) && spree_user_signed_in?) ||
        current_spree_user.present?

      return if signed_in

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
      return [] if current_spree_user.nil?

      @available_memberships ||= current_spree_user.memberships.includes(:gym).select { |membership| membership.active_on?(Date.current) }
    end

    def load_storefront_context
      @current_gym = resolve_current_gym
      @current_membership = resolve_current_membership
    end

    def resolve_current_gym
      return default_gym if current_spree_user.nil?

      memberships = current_spree_user.memberships.includes(:gym)
      return default_gym if memberships.empty?

      active_memberships = memberships.select { |membership| membership.active_on?(Date.current) }

      if params[:gym_slug].present?
        selected = memberships.find { |membership| membership.gym.slug == params[:gym_slug] }
        return selected.gym if selected
      end

      (active_memberships.presence || memberships).max_by(&:starts_on).gym
    end

    def resolve_current_membership
      return nil if current_spree_user.nil? || current_gym.nil?

      current_spree_user.memberships
                        .for_user_and_gym(current_spree_user, current_gym)
                        .active_on(Date.current)
                        .order(starts_on: :desc)
                        .first
    end
  end
end
