class Report
  class Row
    attr_accessor :account, :debit, :credit
  end

  attr_reader :report_rows

  def initialize(accounts, start_date, end_date)
    @start_date = start_date.nil? ? Transaction.first.date : start_date
    @end_date = end_date
    @accounts = accounts
  end

  def run
    @report_rows = []
    @accounts.each do |account|
      row = Row.new
      line_items = account.line_items.where('transactions.date >= ?', @start_date)
        .where('transactions.date <= ?', @end_date)
      row.debit = line_items.sum(&:debit)
      row.credit = line_items.sum(&:credit)

      # Fix in case there were no line items.
      row.debit = 0.to_money if row.debit == 0
      row.credit = 0.to_money if row.credit == 0

      @report_rows << row
    end
    @report_rows
  end
end
