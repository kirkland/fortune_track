module TransactionsHelper
  # TODO: Truncate to reasonable length, add elipsis, add 'expand' link
  def transaction_description(transaction)
    transaction.description.presence || '(no description)'
  end
end
