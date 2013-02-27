module Report
  class GenericReport
    class Row
      attr_accessor :account, :self_debit, :self_credit, :child_rows

      def debit
        @debit ||= self.self_debit + self.child_rows.sum(&:debit).to_money
      end

      def credit
        @credit ||= self.self_credit + self.child_rows.sum(&:credit).to_money
      end
    end

    attr_reader :report_rows

    # Usage: Pass in only your "top level" accounts, because descedants
    # will be automatically included.
    def initialize(accounts, start_date, end_date)
      @start_date = start_date.nil? ? Transaction.last.date : start_date
      @end_date = end_date
      @accounts = accounts

      raise "start_date must be before end_date" if @start_date > @end_date
    end

    def run
      @report_rows = []

      @accounts.each do |account|
        @report_rows << populate_row(Row.new, account)
      end

      @report_rows
    end

    private

    def populate_row(row, account)
      row.account = account
      line_items = account.line_items.where('transactions.date >= ?', @start_date)
        .where('transactions.date <= ?', @end_date)
      row.self_debit = line_items.sum(&:debit)
      row.self_credit = line_items.sum(&:credit)

      # Fix in case there were no line items.
      row.self_debit = 0.to_money if row.self_debit == 0
      row.self_credit = 0.to_money if row.self_credit == 0

      row.child_rows = []
      account.child_accounts.each do |x|
        row.child_rows << populate_row(Row.new, x)
      end

      row
    end
  end
end
