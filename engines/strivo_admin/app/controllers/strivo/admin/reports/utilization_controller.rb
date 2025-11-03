module Strivo
  module Admin
    module Reports
      class UtilizationController < ApplicationController
        def index
          @gyms = Gym.order(:name)
          @selected_gym = resolve_gym(@gyms)
          @start_on = resolve_date(params[:start_on]) || Date.current.beginning_of_week
          @end_on = resolve_date(params[:end_on]) || Date.current.end_of_week

          if @selected_gym.present?
            @report_rows = Reports::BasicUtilization.new(
              gym: @selected_gym,
              start_on: @start_on,
              end_on: @end_on
            ).call
          else
            @report_rows = []
          end
        end

        private

        def resolve_gym(collection)
          return collection.first if params[:gym_id].blank?

          collection.find { |gym| gym.id.to_s == params[:gym_id].to_s } || collection.first
        end

        def resolve_date(value)
          return if value.blank?

          Date.parse(value)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
