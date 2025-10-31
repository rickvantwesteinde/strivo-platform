class WaitlistEntry < ApplicationRecord
  belongs_to :session
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
end
