module Report
  class IncomeReport < GenericReport
    def initialize(start_date, end_date)
      accounts = [Account.find_by_full_name('Income')]
      super(accounts, start_date, end_date)
    end
  end
end
