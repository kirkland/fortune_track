module Report
  class NetWorthReport
    class Row < Struct.new(:date, :amount); end

    attr_reader :report_rows

    def initialize
      @start_date = Date.new 2013, 1, 12
      @end_date = Transaction.first.date
      @report_rows = []
    end

    def run
      @report_rows = (@start_date..@end_date + 1.day).collect do |date|
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
