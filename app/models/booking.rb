class Booking < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :session

  has_one :gym, through: :session
  has_many :credit_ledgers, dependent: :nullify

  enum :status, { confirmed: 0, canceled: 1 }, prefix: true

  validates :user_id, uniqueness: { scope: :session_id }

  scope :upcoming, -> { joins(:session).where('sessions.starts_at >= ?', Time.current).order('sessions.starts_at ASC') }
  scope :past, -> { joins(:session).where('sessions.starts_at < ?', Time.current).order('sessions.starts_at DESC') }
end
