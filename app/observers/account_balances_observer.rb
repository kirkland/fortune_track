class AccountBalancesObserver < ActiveRecord::Observer
  observe :line_item, :transaction

  def after_save(record)
    if record.is_a? LineItem
      account = record.account
      account.update_balances!
      Rails.cache.delete(account.family_debit_cache_key)
      Rails.cache.delete(account.family_credit_cache_key)

      if record.account_id_changed? && record.account_id_was.present?
        account = Account.find(record.account_id_was)
        account.update_balances!
        Rails.cache.delete(account.family_debit_cache_key)
        Rails.cache.delete(account.family_credit_cache_key)
      end
    else
      record.line_items.each do |line_item|
        account = line_item.account
        account.update_balances!
        Rails.cache.delete(account.family_debit_cache_key)
        Rails.cache.delete(account.family_credit_cache_key)

        if line_item.account_id_changed? && line_item.account_id_was.present?
          account = Account.find(line_item.account_id_was)
          account.update_balances!
          Rails.cache.delete(account.family_debit_cache_key)
          Rails.cache.delete(account.family_credit_cache_key)
        end
      end
    end
  end
end
