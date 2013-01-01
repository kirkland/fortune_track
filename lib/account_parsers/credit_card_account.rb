module AccountParsers::CreditCardAccount
  def credit_account
    @credit_account ||= Account.unknown_asset
  end
end
