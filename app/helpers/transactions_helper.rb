module TransactionsHelper
  def account_name(account)
    # If we're viewing this account's list of transactions
    if account == @account
      "<strong>".html_safe + account.full_name + "</strong>".html_safe
#      "<strong>#{account.full_name}</strong>".html_safe
    else
      account.full_name
    end
  end

  # TODO: Truncate to reasonable length, add elipsis, add 'expand' link
  def transaction_description(transaction)
    transaction.description.presence || '(no description)'
  end
end
