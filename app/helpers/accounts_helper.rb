module AccountsHelper
  def indent(account)
    "#{account.depth * 20}px"
  end

  def show_account?(account)
    account.debit_total_with_children != account.credit_total_with_children
  end

  def show_children?(account)
    true
  end

  def has_visible_children?(account)
    account.child_accounts.present? && account.child_accounts.any?{ |x| show_account?(x) }
  end
end
