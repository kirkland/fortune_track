module AccountParsers
  class GenericAccountParser
    attr_accessor :raw_data, :transactions

    def initialize
      @transactions = []
    end

    # Should return primary account for the file parsed, e.g. a bank account or
    # credit card account.
    def primary_account
      subclass_must_define
    end

    # When a transaction is created, if the primary_account has a credit balance,
    # then the account defined here will have a debit balance.
    def debit_account
      subclass_must_define
    end

    # When a transaction is created, if the primary_account has a debit balance,
    # then the account defined here will have a credit balance.
    def credit_account
      subclass_must_define
    end

    # This method will translate @raw_data in to new transactions.
    # Either read_data_from_file or download_data must be called first.
    def build_transactions
      subclass_must_define
    end

    private

    def subclass_must_define
      # TODO: can we find out what the name of the method is?
      raise "Subclass must define this method."
    end

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Date.parse("#{year}-#{month}-#{day}")
    end
  end
end
