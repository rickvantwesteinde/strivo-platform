class Spree::User < Spree.base_class
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Spree modules
  include Spree::UserAddress
  include Spree::UserMethods
  include Spree::UserPaymentSource

  has_many :bookings, dependent: :destroy, foreign_key: :user_id
  has_many :credit_ledgers, dependent: :destroy, foreign_key: :user_id
  has_many :subscriptions, dependent: :destroy, foreign_key: :user_id
  has_many :waitlist_entries, dependent: :destroy, foreign_key: :user_id
  has_many :trainers, dependent: :destroy, foreign_key: :user_id
end
