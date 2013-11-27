class LineItem < ActiveRecord::Base
  include Monetizable

  # Attributes
  attr_accessible :account, :account_id, :debit, :credit

  # Associations
  belongs_to :transaction
  belongs_to :account

  # Validations
  validates_presence_of :account
  validates_presence_of :transaction

  # Scopes
  default_scope includes(:transaction).where('transactions.duplicate_transaction_id IS NULL')

  money :credit
  money :debit
end
