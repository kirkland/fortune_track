require 'csv'

module AccountParsers
  class CentralBankParser < GenericAccountParser
    def initialize
      @transactions = []
    end

    def parse_transactions
      filename = File.join(Rails.root, 'notes/sample_data/central_bank.csv') if filename.nil?
      CSV.foreach(filename) do |row|
        if row.length == 1 || row[0] == 'Transaction Number'
          next
        end

        transaction = Transaction.new
        transaction.unique_code = row[0]
        transaction.date = parse_date row[1]
        transaction.description = row[2]

        outflow = row[4].to_s.strip =~ /^-/

        amount = row[4].to_s.strip.present? ? row[4].to_s.strip.sub(/-/, '') : row[5].to_s.strip.sub(/-/, '')
        amount = amount.to_money

        if outflow
          asset = transaction.line_items.build
          asset.account = Account.all.detect{|x| x.name =~ /Central Bank/}
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = Account.find_by_full_name 'Expenses:Unknown'
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = Account.all.detect{|x| x.name =~ /Central Bank/}
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
