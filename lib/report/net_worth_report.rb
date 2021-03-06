module Report
  class NetWorthReport
    class Row < Struct.new(:date, :amount); end

    attr_reader :report_rows

    def initialize
      @start_date = Date.new 2013, 2, 1
      @end_date = Transaction.first.date + 1.month
      @report_rows = []
    end

    def run
      dates = []
      current_date = @start_date
      while ( current_date < @end_date )
        dates << current_date
        current_date = current_date + 1.month
      end

      @report_rows = dates.collect do |date|
        puts "Calculating for #{date}..."

        asset_lis = LineItem.includes(:transaction).where('transactions.date < ?', date)
          .where('transactions.duplicate_transaction_id IS NULL')
          .where(account_id: Account.where('full_name LIKE ?', 'Assets:%').collect(&:id)).all

        asset_balance = asset_lis.sum(&:debit) - asset_lis.sum(&:credit)

        liability_lis = LineItem.includes(:transaction).where('transactions.date < ?', date)
          .where(account_id: Account.where('full_name LIKE ?', 'Liabilities:%').collect(&:id)).all

        liability_balance = liability_lis.sum(&:credit) - liability_lis.sum(&:debit)

        Row.new(date, (asset_balance - liability_balance))
      end

      @report_rows.reject{|x| x.amount < 0} # Reject early, nonsensical balances.
    end
  end
end
