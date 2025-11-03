class Spree::User < Spree.base_class
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Spree modules
  include Spree::UserAddress
  include Spree::UserMethods
  include Spree::UserPaymentSource
<<<<<<< HEAD

  has_many :bookings, dependent: :destroy, foreign_key: :user_id
  has_many :credit_ledgers, dependent: :destroy, foreign_key: :user_id
  has_many :subscriptions, dependent: :destroy, foreign_key: :user_id
  has_many :waitlist_entries, dependent: :destroy, foreign_key: :user_id
  has_many :trainers, dependent: :destroy, foreign_key: :user_id
=======
>>>>>>> parent of 7c2f58f0 (feat(storefront): booking MVP (sessions list, book/cancel, my bookings) (#16))
end
