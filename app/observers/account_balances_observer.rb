class AccountBalancesObserver < ActiveRecord::Observer
  observe :line_item, :transaction

  def after_save(record)
    if record.is_a? LineItem
      record.account.update_balances!
    else
      record.line_items.each do |line_item|
        line_item.account.update_balances!
      end
    end
  end
end
