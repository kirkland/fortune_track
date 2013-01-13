module Reports
  class ExpenseReport
    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date

      raise "start_date must be before end_date" if @start_date > @end_date
    end

    def report
      @accounts = Account.all.select { |x| x.full_name =~ /^Expense/ }

      total_expenses = @accounts.sum do |account|
        account.line_items.select{|x| x.transaction.date >= @start_date && x.transaction.date <= @end_date}.sum(&:debit_amount)
      end

      @report_rows = @accounts.collect do |account|
        r = AccountReportRow.new(account)

        transactions = Account.all.select{|x| x.full_name =~ /^#{account.full_name}/}.collect do |account|
          account.transactions.where("transactions.date > ? AND transactions.date <= ?", @start_date, @end_date)
        end.flatten

        total_debit = transactions.collect(&:line_items).flatten.uniq.select{|x| x.account.full_name =~ /^#{account.full_name}/}.sum(&:debit).to_money
        total_credit = transactions.collect(&:line_items).flatten.uniq.select{|x| x.account.full_name =~ /^#{account.full_name}/}.sum(&:credit).to_money

        r.values[:amount] = total_debit - total_credit
        r.values[:percent_total] = "%0.2f" % (r.values[:amount].to_f / total_expenses * 10000)

        r
      end

      @report_rows = @report_rows.select do |row|
        row.values[:amount] > 0
      end

      @report_rows
    end
  end
end
