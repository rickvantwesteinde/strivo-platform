# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Storefront Dashboard", type: :feature do
  let!(:gym)         { create(:default_gym) }
  let(:user)         { create(:spree_user) }
  let(:class_type)   { create(:class_type, gym: gym, name: "HIIT") }
  let(:trainer_user) { create(:spree_user, name: "Jan") }
  let(:trainer)      { create(:trainer, gym: gym, user: trainer_user) }

  before do
    login_as(user, scope: :spree_user)
  end

  scenario "User views dashboard with sessions and credits" do
    # Zet de sessie expliciet in de toekomst (voorkomt filtering)
    create(:session, class_type: class_type, trainer: trainer,
                     start_at: 2.hours.from_now, capacity: 14)
    CreditLedger.create!(user: user, gym: gym, amount: 5, reason: :monthly_grant)

    # Bezoek direct het dashboard i.p.v. root (Spree home)
    visit "/storefront/dashboard"

    # Functionele checks (taal- en layout-onafhankelijk)
    expect(page).to have_content("Credits")
    expect(page).to have_content("5")
    expect(page).to have_content("HIIT")
    expect(page).to have_content("Jan")
    expect(page).to have_button(/Boek|Book/i)
  end
end
