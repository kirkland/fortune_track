class LineItem < ActiveRecord::Base
  attr_accessible :credit_in_cents, :debit_in_cents, :account_id, :debit, :credit

  belongs_to :transaction
  belongs_to :account

  validates_presence_of :debit_in_cents
  validates_presence_of :credit_in_cents
  validates_presence_of :account
  validates_presence_of :transaction

  before_validation do
    set_defaults
  end

  def credit
    credit_in_cents.to_f / 100
  end

  def credit=(amount)
    self.credit_in_cents = amount.to_f * 100
  end

  def debit
    debit_in_cents.to_f / 100
  end

  def debit=(amount)
    self.debit_in_cents = amount.to_f * 100
  end

  private

  def set_defaults
    self.debit_in_cents = 0 if debit_in_cents.blank?
    self.credit_in_cents = 0 if credit_in_cents.blank?
  end
end
