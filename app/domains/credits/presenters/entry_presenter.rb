module Credits
  module Presenters
    class EntryPresenter
      attr_reader :entry, :view
      def initialize(entry, view); @entry, @view = entry, view; end
      def date   = view.l(entry.created_at, format: :short)
      def reason = entry.reason.presence || "-"
      def amount = entry.amount
    end
  end
end
