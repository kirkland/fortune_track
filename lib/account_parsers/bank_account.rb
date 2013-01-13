module AccountImporters::BankAccount
  def credit_account
    @credit_account ||= Account.unknown_income
  end
end
