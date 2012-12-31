module AccountParsers::CreditCardAccount
  def credit_account
    @credit_account ||= Account.find_or_create_by_full_name 'Assets:Unknown'
  end
end
