require 'csv'

module AccountParsers
  class BankOfAmericaParser < GenericAccountParser

    def primary_account
      @primary_account ||= Account.all.detect{|x| x.name =~ /Bank of America/}
    end

    def credit_account
      @credit_account ||= Account.find_by_full_name 'Income:Unknown'
    end

    def build_transactions(filename=nil)
      CSV.parse(@raw_data).each do |row|
        next if row.length < 4 || row[0] == 'Date' || row[1] =~ /Beginning balance/

        transaction = Transaction.new
        transaction.unique_code = row.join ','
        transaction.date = parse_date row[0]
        transaction.description = row[1]

        outflow = row[2].to_s.strip =~ /^-/

        amount = row[2].sub(/^-/, '').to_money

        if outflow
          asset = transaction.line_items.build
          asset.account = primary_account
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = debit_account
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = primary_account
          asset.debit = amount

          income = transaction.line_items.build
          income.account = credit_account
          income.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/bank_of_america.txt')
    end

  end
end
