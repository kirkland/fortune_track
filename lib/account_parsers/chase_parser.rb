require 'csv'

module AccountParsers
  class ChaseParser < GenericAccountParser
    def initialize
      @transactions = []
    end

    def parse_transactions(filename=nil)
      filename = File.join(Rails.root, 'notes/sample_data/chase_amazon.csv') if filename.nil?
      CSV.foreach(filename) do |row|
        next if row[0] == 'Type'

        transaction = Transaction.new
        transaction.unique_code = row.join(' - ')
        transaction.date = parse_date row[1]
        transaction.description = row[3]

        outflow = row[0] == 'Sale'

        amount = row[4].to_s.strip.sub(/-/, '').to_money

        if outflow
          liability = transaction.line_items.build
          liability.account = Account.all.detect{|x| x.name =~ /Amazon/}
          liability.credit = amount

          expense = transaction.line_items.build
          expense.account = Account.find_by_full_name 'Expenses:Unknown'
          expense.debit = amount
        else
          liability = transaction.line_items.build
          liability.account = Account.all.detect{|x| x.name =~ /Amazon/}
          liability.debit = amount

          asset = transaction.line_items.build
          asset.account = Account.find_by_full_name 'Assets:Unknown'
          asset.credit = amount
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
