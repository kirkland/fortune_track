module Reports
  class ExpenseReport
    class ReportRow < Struct.new(:account, :amount); end

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date

      raise "start_date must be before end_date" if @start_date > @end_date
    end

    def report
      @accounts = Account.all.select { |x| x.full_name =~ /^Expense/ }
      @report_rows = @accounts.collect do |account|
        r = ReportRow.new
        r.account = account

        transactions = Account.all.select{|x| x.full_name =~ /^#{account.full_name}/}.collect do |account|
          account.transactions.where("transactions.date > ? AND transactions.date <= ?", @start_date, @end_date)
        end.flatten

        total_debit = transactions.collect(&:line_items).flatten.uniq.select{|x| x.account.full_name =~ /^#{account.full_name}/}.sum(&:debit).to_money
        total_credit = transactions.collect(&:line_items).flatten.uniq.select{|x| x.account.full_name =~ /^#{account.full_name}/}.sum(&:credit).to_money

        r.amount = total_debit - total_credit

        r
      end

      @report_rows = @report_rows.select do |row|
        row.amount > 0
      end

      @report_rows
    end
  end
end
