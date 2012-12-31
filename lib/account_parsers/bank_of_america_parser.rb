require 'csv'

module AccountParsers
  class BankOfAmericaParser < GenericAccountParser

    def parse_transactions(filename=nil)
      filename = File.join(Rails.root, 'notes/sample_data/bank_of_america.txt') if filename.nil?
      CSV.foreach(filename) do |row|
        next if row.length < 4 || row[0] == 'Date' || row[1] =~ /Beginning balance/

        transaction = Transaction.new
        transaction.unique_code = row.join ','
        transaction.date = parse_date row[0]
        transaction.description = row[1]

        outflow = row[2].to_s.strip =~ /^-/

        amount = row[2].sub(/^-/, '').to_money

        if outflow
          asset = transaction.line_items.build
          asset.account = Account.all.detect{|x| x.name =~ /Bank of America/}
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = Account.find_by_full_name 'Expenses:Unknown'
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = Account.all.detect{|x| x.name =~ /Bank of America/}
          asset.debit = amount

          income = transaction.line_items.build
          income.account = Account.find_by_full_name 'Income:Unknown'
          income.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    def read_data_from_file
      # no-op
    end

    private

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Date.parse "#{year}-#{month}-#{day}"
    end
  end
end

