# frozen_string_literal: true

module Storefront
  class ClassesController < BaseController
    def index
      @class_types = ClassType.order(:name)
      # Komende sessies groeperen per class_type voor de view
      upcoming_sessions = Session.where('starts_at >= ?', Time.current).order(:starts_at)
      @sessions_by_class_type = upcoming_sessions.group_by(&:class_type_id)
    end
  end
end
