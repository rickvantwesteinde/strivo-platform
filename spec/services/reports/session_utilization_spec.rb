# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::SessionUtilization do
  let(:gym) { create(:gym) }
  let(:class_type) { create(:class_type, gym: gym) }
  let(:trainer) { create(:trainer, gym: gym) }
  let(:session_record) { create(:session, class_type: class_type, trainer: trainer, capacity: 10) }

  it 'returns bookings and no-show counts' do
    plan = create(:subscription_plan, gym: gym)
    user_one = create(:spree_user)
    user_two = create(:spree_user)
    user_three = create(:spree_user)

    create(:booking, session: session_record, user: user_one, subscription_plan: plan, used_credits: 1)
    create(:booking, session: session_record, user: user_two, subscription_plan: plan,
                     used_credits: 1, no_show: true)
    create(:booking, session: session_record, user: user_three, subscription_plan: plan,
                     used_credits: 1, status: :canceled)

    report = described_class.new(session_record).call

    expect(report[:session_id]).to eq(session_record.id)
    expect(report[:bookings_count]).to eq(1) # Only confirmed, non-canceled
    expect(report[:capacity]).to eq(10)
    expect(report[:no_shows_count]).to eq(1)
  end
end
