class Transaction < ActiveRecord::Base
  attr_accessible  :description, :date, :duplicate_transaction_id

  has_many :line_items, dependent: :destroy, inverse_of: :transaction, order: 'id ASC'

  # The record with duplicate_transaction_id populated is the duplicate, and will be ignored.
  belongs_to :duplicate_transaction, class_name: 'Transaction'

  validate :debits_equals_credits
  validate :validates_has_line_item
  validates :date, presence: true

  after_save :delete_empty_line_items

  default_scope where('date > ?', Date.new(2012,12,01))
                .where('duplicate_transaction_id IS NULL')

  private

  def debits_equals_credits
    if line_items.collect(&:debit).sum != line_items.collect(&:credit).sum
      errors.add(:line_items, 'total debits must equal total credits')
    end
  end

  def delete_empty_line_items
    line_items.each do |line_item|
      line_item.destroy if line_item.debit == 0 && line_item.credit == 0
    end
  end

  def validates_has_line_item
    if line_items.length == 0
      errors.add(:line_items, 'must have at least one line item')
    end
  end
end
