# frozen_string_literal: true

module Storefront
  class ClassesController < BaseController
    def index
      @class_types = ClassType.all
    end

    def show
      @class_type = ClassType.find(params[:id])
      @sessions = @class_type.sessions
                             .where('starts_at >= ?', Time.zone.now.beginning_of_day)
                             .order(:starts_at)
    end
  end
end
