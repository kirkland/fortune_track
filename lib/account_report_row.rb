class AccountReportRow
  attr_accessor :account, :values

  def initialize(account)
    self.account = account
    self.values = {}
  end
end
