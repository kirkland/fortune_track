require 'csv'

module AccountParsers
  class ChaseParser < GenericAccountParser

    def primary_account
      @primary_account ||= Account.all.detect{|x| x.name =~ /Amazon/}
    end

    def debit_account
      @debit_account ||= Account.find_by_full_name 'Expenses:Unknown'
    end

    def credit_account
      @credit_account ||= Account.find_by_full_name 'Assets:Unknown'
    end

    def build_transactions(filename=nil)
      CSV.parse(@raw_data).each do |row|
        next if row[0] == 'Type'

        transaction = Transaction.new
        transaction.unique_code = row.join(' - ')
        transaction.date = parse_date row[1]
        transaction.description = row[3]

        outflow = row[0] == 'Sale'

        amount = row[4].to_s.strip.sub(/-/, '').to_money

        if outflow
          liability = transaction.line_items.build
          liability.account = primary_account
          liability.credit = amount

          expense = transaction.line_items.build
          expense.account = debit_account
          expense.debit = amount
        else
          liability = transaction.line_items.build
          liability.account = primary_account
          liability.debit = amount

          asset = transaction.line_items.build
          asset.account = credit_account
          asset.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/chase_amazon.csv')
    end

  end
end
