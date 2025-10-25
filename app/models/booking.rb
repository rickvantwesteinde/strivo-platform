class Booking < ApplicationRecord
  enum :status, { confirmed: 0, canceled: 1 }, prefix: true
end
