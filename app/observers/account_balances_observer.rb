class AccountBalancesObserver < ActiveRecord::Observer
  observe :line_item, :transaction

  def after_save(record)
    if record.is_a? LineItem
      record.account.update_balances!

      if record.account_id_changed?
        Account.find(record.account_id_was).update_balances!
      end
    else
      record.line_items.each do |line_item|
        line_item.account.update_balances!

        if line_item.account_id_changed?
          Account.find(line_item.account_id_was).update_balances!
        end
      end
    end
  end
end
