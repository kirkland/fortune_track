class LineItem < ActiveRecord::Base
  attr_accessible :credit_in_cents, :debit_in_cents, :account_id

  belongs_to :transaction
  belongs_to :account

  validates_presence_of :debit_in_cents
  validates_presence_of :credit_in_cents
  validates_presence_of :account
  validates_presence_of :transaction

  before_validation on: :create do
    set_defaults
  end

  private

  def set_defaults
    self.debit_in_cents = 0 if debit_in_cents.blank?
    self.credit_in_cents = 0 if credit_in_cents.blank?
  end
end
