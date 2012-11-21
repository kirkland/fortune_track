class LineItem < ActiveRecord::Base
  belongs_to :transaction
  belongs_to :account

  validates_presence_of :debit_in_cents
  validates_presence_of :credit_in_cents
  validates_presence_of :account
  validates_presence_of :transaction
end
