class Transaction < ActiveRecord::Base
  attr_accessible  :description, :date, :line_items

  has_many :line_items, dependent: :destroy, inverse_of: :transaction
#  accepts_nested_attributes_for :line_items

  validate :debits_equals_credits

  private

  def debits_equals_credits
    if line_items.sum(&:debit_in_cents) != line_items.sum(&:credit_in_cents)
      errors.add(:line_items, 'total debits must equal total credits')
    end
  end
end
