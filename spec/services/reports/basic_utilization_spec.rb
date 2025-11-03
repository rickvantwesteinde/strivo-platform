require 'rails_helper'

RSpec.describe Reports::BasicUtilization do
  let(:gym) { Gym.create!(name: 'HQ', slug: 'hq') }
  let(:class_type) { ClassType.create!(gym:, name: 'Strength') }
  let!(:session_one) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: Date.current.beginning_of_day.change(hour: 10),
      capacity: 5,
      trainer_name: 'Trainer One'
    )
  end
  let!(:session_two) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: Date.current.beginning_of_day.change(hour: 14),
      capacity: 10,
      trainer_name: 'Trainer Two'
    )
  end

  before do
    3.times do |index|
      Booking.create!(
        user: Spree::User.create!(email: "member-one-#{index}@example.com", password: 'Password1!', password_confirmation: 'Password1!'),
        session: session_one,
        status: :confirmed
      )
      Booking.create!(
        user: Spree::User.create!(email: "member-two-#{index}@example.com", password: 'Password1!', password_confirmation: 'Password1!'),
        session: session_two,
        status: :confirmed
      )
    end
  end

  it 'returns utilization rows with fill rates' do
    report = described_class.new(gym:, start_on: Date.current, end_on: Date.current).call

    expect(report.size).to eq(2)

    first_row = report.first
    expect(first_row.session_id).to eq(session_one.id)
    expect(first_row.confirmed_bookings).to eq(3)
    expect(first_row.capacity).to eq(5)
    expect(first_row.fill_rate).to be_within(0.01).of(0.6)

    second_row = report.second
    expect(second_row.confirmed_bookings).to eq(3)
    expect(second_row.capacity).to eq(10)
    expect(second_row.fill_rate).to be_within(0.01).of(0.3)
  end

  it 'returns empty array when no sessions match' do
    report = described_class.new(gym:, start_on: Date.current + 7.days, end_on: Date.current + 8.days).call

    expect(report).to be_empty
  end
end
