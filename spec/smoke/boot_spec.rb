# frozen_string_literal: true
RSpec.describe 'Boot', type: :request do
  it 'boots Rails and connects to DB' do
    expect(ActiveRecord::Base.connection).to be_present
  end
end
