# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe '.active_on_day' do
    let(:gym) { create(:gym) }
    let(:class_type) { create(:class_type, gym: gym) }
    let(:trainer) { create(:trainer, gym: gym) }
    let(:user) { create(:spree_user) }
    let(:date) { Date.new(2024, 1, 10) }
    let(:session_one) do
      create(:session, class_type: class_type, trainer: trainer,
                       starts_at: Time.zone.local(2024, 1, 10, 9, 0, 0))
    end
    let(:session_two) do
      create(:session, class_type: class_type, trainer: trainer,
                       starts_at: Time.zone.local(2024, 1, 10, 18, 0, 0))
    end

    it 'returns confirmed bookings on the given day' do
      subscription_plan = create(:subscription_plan, gym: gym)
      booking_one = create(:booking, session: session_one, user: user,
                                     subscription_plan: subscription_plan, used_credits: 0)
      booking_two = create(:booking, session: session_two, user: user,
                                     subscription_plan: subscription_plan, used_credits: 0)
      booking_two.update!(status: :canceled)

      result = described_class.active_on_day(user, date)

      expect(result).to contain_exactly(booking_one)
    end
  end

  describe '#cancel!' do
    it 'sets status to canceled and updates canceled_at' do
      booking = create(:booking)
      canceled_at = Time.current

      booking.cancel!(canceled_at: canceled_at)

      expect(booking.reload.status_canceled?).to be true
      expect(booking.canceled_at).to be_within(1.second).of(canceled_at)
    end
  end
end
