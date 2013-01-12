module AccountsHelper
  def indent(account)
    "#{account.depth * 20}px"
  end

  def show_account?(account)
    @show_all || account.family_debit_total != account.family_credit_total
  end

  def show_children?(account)
    account.depth < 1
    true
  end

  def has_visible_children?(account)
    (@show_all && account.child_accounts.present?) ||
      account.child_accounts.present? && account.child_accounts.any?{ |x| show_account?(x) }
  end
end
