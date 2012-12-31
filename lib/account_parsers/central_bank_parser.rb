require 'csv'

module AccountParsers
  class CentralBankParser < GenericAccountParser

    include BankAccount

    def primary_account
      @primary_account ||= Account.all.detect{|x| x.name =~ /Central Bank/}
    end

    def build_transactions
      CSV.parse(@raw_data).each do |row|
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
      File.join(Rails.root, 'notes/sample_data/central_bank.csv')
    end

  end
end
