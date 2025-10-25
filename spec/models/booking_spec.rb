require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe ".active_on_day" do
    let(:gym) { create(:gym) }
    let(:class_type) { create(:class_type, gym:) }
    let(:trainer) { create(:trainer, gym:) }
    let(:user) { create(:spree_user) }
    let(:date) { Date.new(2024, 1, 10) }
    let(:session_one) { create(:session, class_type:, trainer:, starts_at: Time.zone.local(2024, 1, 10, 9, 0, 0)) }
    let(:session_two) { create(:session, class_type:, trainer:, starts_at: Time.zone.local(2024, 1, 10, 18, 0, 0)) }

    it "returns confirmed bookings on the given day" do
      booking_one = create(:booking, session: session_one, user:, subscription_plan: create(:subscription_plan, gym:), used_credits: 0)
      booking_two = create(:booking, session: session_two, user:, subscription_plan: booking_one.subscription_plan, used_credits: 0)
      booking_two.update!(status: :canceled)

      result = described_class.active_on_day(user, date)

      expect(result).to contain_exactly(booking_one)
    end
  end
end
