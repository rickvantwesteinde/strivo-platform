class CreditLedger < ApplicationRecord
  enum :reason,
       {
         monthly_grant: 0,
         booking_charge: 1,
         booking_refund: 2,
         rollover_expiry: 3,
         manual_adjustment: 4
       },
       prefix: true
end
