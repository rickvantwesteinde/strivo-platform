# frozen_string_literal: true

module Storefront
  class ClassesController < Storefront::BaseController
    layout "spree_application"

    def index
      # --- Gym & membership (defensief) ---
      @gym = respond_to?(:current_gym, true) ? current_gym : (defined?(Gym) ? Gym.first : nil)
      @active_membership = respond_to?(:current_membership, true) ? current_membership : nil

      # --- Class types ---
      @class_types =
        begin
          if @gym && @gym.respond_to?(:class_types)
            @gym.class_types.order(:name)
          elsif defined?(ClassType)
            ClassType.order(:name)
          else
            []
          end
        rescue
          []
        end

      # --- Sessies (met starts_at of start_at fallback) ---
      @sessions_by_class_type = {}

      if defined?(Session)
        scope = @gym&.respond_to?(:sessions) ? @gym.sessions : Session.all

        datetime_column =
          if Session.column_names.include?("starts_at")
            "starts_at"
          elsif Session.column_names.include?("start_at")
            "start_at"
          else
            nil
          end

        upcoming =
          if datetime_column
            scope.where("#{datetime_column} >= ?", Time.current)
                 .order(datetime_column.to_sym)
          else
            scope.none
          end

        # Eager load als beschikbaar
        if Session.reflect_on_association(:class_type)
          upcoming = upcoming.includes(:class_type)
        end
        if (assoc = Session.reflect_on_association(:trainer))
          # probeer trainer.user ook mee te nemen
          if assoc.klass&.reflect_on_association(:user)
            upcoming = upcoming.includes(trainer: :user)
          else
            upcoming = upcoming.includes(:trainer)
          end
        end

        @sessions_by_class_type = upcoming.group_by do |s|
          s.try(:class_type_id) || s.try(:class_type)&.try(:id)
        end
      end
    end
  end
end