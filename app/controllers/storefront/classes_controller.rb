# frozen_string_literal: true

module Storefront
  class ClassesController < BaseController
    def index
      @class_types = current_gym.class_types.order(:name)
      # Komende sessies groeperen per class_type voor de view
      upcoming_sessions = current_gym.sessions.where('starts_at >= ?', Time.current).order(:starts_at)
      @sessions_by_class_type = upcoming_sessions.group_by(&:class_type_id)
      @active_membership = current_membership
    end
  end
end
