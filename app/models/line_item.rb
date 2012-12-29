class LineItem < ActiveRecord::Base
  include Monetizable

  attr_accessible :account, :account_id, :debit, :credit

  belongs_to :transaction
  belongs_to :account

  validates_presence_of :account
  validates_presence_of :transaction

  default_scope joins(:transaction).where('transactions.date > ?', Date.new(2012,12,01)).where('transactions.duplicate_transaction_id IS NULL')

  money :credit
  money :debit
end
