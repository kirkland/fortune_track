class AccountBalancesObserver < ActiveRecord::Observer
  observe :line_item, :transaction

  def after_save(record)
    if record.is_a? LineItem
      line_item_changed(record)
    else
      transaction_changed(record)
    end
  end

  def line_item_changed(line_item)
    debit_difference = line_item.debit_was - line_item.debit
    line_item.account.debit_total += debit_difference
    line_item.account.save!
  end

  def transaction_changed(transaction)
    line_items = transaction.line_items

    if transaction.duplicate_transaction_id.present? && transaction.duplicate_transaction_id_was.nil?
      line_items.each do |line_item|
        line_item.account.debit_total -= line_item.debit
        line_item.account.credit_total -= line_item.credit
      end
    elsif transaction.duplicate_transaction_id_was.present? && transaction.duplicate_transaction_id.nil?
      line_items.each do |line_item|
        line_item.account.debit_total += line_item.debit
        line_item.account.credit_total += line_item.credit
      end
    end
  end
end
