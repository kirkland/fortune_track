require 'csv'

module AccountParsers
  class IngDirectParser < GenericAccountParser

    def build_transactions(filename=nil)
      filename = File.join(Rails.root, 'notes/sample_data/ing_direct.csv') if filename.nil?
      CSV.foreach(filename) do |row|
        next if row[0] == 'BANK ID' || row.blank?

        transaction = Transaction.new
        transaction.unique_code = row.join(',')
        transaction.date = Date.parse row[7]
        transaction.description = row[10]

        outflow = row[6] == 'DEBIT'

        amount = row[8].sub(/-/, '').to_money

        asset_account = case row[1]
          when '540524954' then Account.all.detect{|x| x.full_name =~ /ING Direct:Checking/ }
          when '123567907' then Account.all.detect{|x| x.full_name =~ /ING Direct:Savings/ }
          when '165003188' then Account.all.detect{|x| x.full_name =~ /ING Direct:Espresso/ }
        end

        if outflow
          asset = transaction.line_items.build
          asset.account = asset_account
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = Account.find_by_full_name 'Expenses:Unknown'
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = asset_account
          asset.debit = amount

          income = transaction.line_items.build
          income.account = Account.find_by_full_name 'Income:Unknown'
          income.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

  end
end
