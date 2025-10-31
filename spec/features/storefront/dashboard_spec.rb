require 'rails_helper'

RSpec.feature 'Storefront Dashboard', type: :feature do
  let(:gym) { create(:gym, name: 'X Gym') }
  let(:user) { create(:spree_user) }
  let(:class_type) { create(:class_type, gym: gym, name: 'HIIT') }
  let(:trainer) { create(:trainer, gym: gym, user: create(:spree_user, name: 'Jan')) }

  before do
    allow_any_instance_of(Storefront::BaseController).to receive(:current_gym).and_return(gym)
    sign_in user
  end

  scenario 'User views dashboard with sessions and credits' do
    create(:session, class_type: class_type, trainer: trainer, starts_at: Time.current, capacity: 14)
    CreditLedger.create!(user: user, gym: gym, amount: 5, reason: :monthly_grant)

    visit root_path

    expect(page).to have_content('Welkom bij X Gym')
    expect(page).to have_content('Credits')
    expect(page).to have_content('5')
    expect(page).to have_content('HIIT')
    expect(page).to have_content('Jan')
    expect(page).to have_button('Boeken')
  end
end