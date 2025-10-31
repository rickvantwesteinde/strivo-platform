class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :trainer
  delegate :gym, to: :class_type
end
