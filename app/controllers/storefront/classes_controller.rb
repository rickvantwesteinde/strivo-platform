module Storefront
  class ClassesController < BaseController
    UPCOMING_WINDOW_DAYS = 14
    SESSIONS_PER_TYPE = 5

    def index
      range_end = UPCOMING_WINDOW_DAYS.days.from_now.end_of_day
      sessions = Session.includes(:class_type, :gym).upcoming(until_time: range_end)
      @class_types = ClassType.includes(:gym).order(:name)
      grouped = sessions.group_by(&:class_type_id)
      @sessions_by_class_type = grouped.transform_values { |items| items.first(SESSIONS_PER_TYPE) }
    end
  end
end
