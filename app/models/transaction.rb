class Transaction < ActiveRecord::Base
  has_many :line_items, dependent: :destroy

  validate :
end
