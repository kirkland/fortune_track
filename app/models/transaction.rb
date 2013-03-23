class Transaction < ActiveRecord::Base
  attr_accessible  :description, :date, :duplicate_transaction_id

  has_many :line_items, dependent: :destroy, inverse_of: :transaction, order: 'line_items.id ASC',
    autosave: true

  # The record with duplicate_transaction_id populated is the duplicate, and will be ignored.
  belongs_to :duplicate_transaction, class_name: 'Transaction'

  validate :debits_equals_credits
  validate :validates_has_line_item
  validates :date, presence: true

  after_save :delete_empty_line_items

  default_scope where('duplicate_transaction_id IS NULL').order('date DESC')

  # Changing how unique_code is calculated for CapOne, so need to update existing ones.
  def self.update_capital_one_unique_codes
    Account.find(433).transactions.each do |t|
      old = t.unique_code
      split = old.split(':') rescue ['a', 'b', 'c', 'd']
      t.unique_code = %{#{split[0]}:#{split[1]}:#{split[3]}}
      t.save!
    end
  end

  private

  def debits_equals_credits
    will_save = line_items.select { |x| !x.marked_for_destruction? }
    if will_save.collect(&:debit).sum != will_save.collect(&:credit).sum
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
