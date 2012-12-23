class LineItem < ActiveRecord::Base
  include Monetizable

  attr_accessible :account, :account_id, :debit, :credit

  belongs_to :transaction
  belongs_to :account

  validates_presence_of :account
  validates_presence_of :transaction

  money :credit
  money :debit
end
