# frozen_string_literal: true
module ApplicationHelper
  # bestaand: je wilde 'm altijd tonen (kan later conditioneel)
  def bottom_nav_present?
    true
  end

  # unified datetime getter: werkt met starts_at of start_at
  def session_datetime(record)
    return nil unless record
    if record.respond_to?(:starts_at) && record.starts_at.present?
      record.starts_at
    elsif record.respond_to?(:start_at)
      record.start_at
    end
  end

  # geeft string kolomnaam voor ORDER BY
  def session_datetime_column
    return "starts_at" if defined?(Session) && Session.column_names.include?("starts_at")
    return "start_at"  if defined?(Session) && Session.column_names.include?("start_at")
    nil
  end
end