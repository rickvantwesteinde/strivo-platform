require 'rails_helper'

RSpec.describe Reports::SessionUtilization do
  let(:session_record) { create(:session, capacity: 10) }

  it "returns bookings and no-show counts" do
    plan = create(:subscription_plan, gym: session_record.gym)
    user_one = create(:spree_user)
    user_two = create(:spree_user)

    create(:booking, session: session_record, user: user_one, subscription_plan: plan, used_credits: 1)
    create(:booking, session: session_record, user: user_two, subscription_plan: plan, used_credits: 1, no_show: true)
    create(:booking, session: session_record, user: create(:spree_user), subscription_plan: plan, used_credits: 1, status: :canceled)

    report = described_class.new(session_record).call

    expect(report[:session_id]).to eq(session_record.id)
    expect(report[:bookings_count]).to eq(1)
    expect(report[:capacity]).to eq(10)
    expect(report[:no_shows_count]).to eq(1)
  end
end
