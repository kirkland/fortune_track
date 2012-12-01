class Transaction < ActiveRecord::Base
  attr_accessible  :description, :date

  has_many :line_items, dependent: :destroy, inverse_of: :transaction, order: 'id ASC'

  validate :debits_equals_credits

  private

  def debits_equals_credits
    if line_items.collect(&:debit_in_cents).sum != line_items.collect(&:credit_in_cents).sum
      errors.add(:line_items, 'total debits must equal total credits')
    end
  end
end
