module BankAccount
  def credit_account
    @credit_account ||= Account.find_by_full_name 'Income:Unknown'
  end
end
