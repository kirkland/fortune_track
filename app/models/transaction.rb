class Transaction < ActiveRecord::Base
  attr_accessible  :description, :date

  has_many :line_items, dependent: :destroy, inverse_of: :transaction, order: 'id ASC'

  validate :debits_equals_credits

  after_save :delete_empty_line_items

  private

  def debits_equals_credits
    if line_items.collect(&:debit_in_cents).sum != line_items.collect(&:credit_in_cents).sum
      errors.add(:line_items, 'total debits must equal total credits')
    end
  end

  def delete_empty_line_items
    line_items.each do |line_item|
      line_item.destroy if line_item.debit_in_cents == 0 && line_item.credit_in_cents == 0
    end
  end
end
