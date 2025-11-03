require 'rails_helper'

RSpec.describe 'Strivo Admin Utilization Report', type: :request do
  let(:admin_password) { 'Password1!' }
  let(:admin) { Spree::AdminUser.create!(email: 'admin@example.com', password: admin_password, password_confirmation: admin_password) }
  let(:gym) { Gym.create!(name: 'Report Gym', slug: 'report-gym') }
  let(:class_type) { ClassType.create!(gym:, name: 'Conditioning') }
  let!(:session_record) do
    Session.create!(
      gym:,
      class_type:,
      starts_at: Date.current.change(hour: 9),
      capacity: 4,
      trainer_name: 'Coach Report'
    )
  end
  let!(:user) { Spree::User.create!(email: 'member@example.com', password: 'Password1!', password_confirmation: 'Password1!') }

  before do
    Booking.create!(user:, session: session_record, status: :confirmed)
  end

  let(:path) { '/admin/strivo/reports/utilization' }

  it 'requires authentication' do
    get path

    expect(response).to have_http_status(:found)
    expect(response.location).to include('/admin_user/sign_in')
  end

  it 'renders the report for authenticated admins' do
    sign_in admin, scope: :spree_admin_user

    get path, params: { gym_id: gym.id, start_on: Date.current.to_s, end_on: Date.current.to_s }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Bezettingsrapport')
    expect(response.body).to include(gym.name)
    expect(response.body).to include(class_type.name)
    expect(response.body).to include('1')
  end
end
