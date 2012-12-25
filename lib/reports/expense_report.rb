module Reports
  class ExpenseReport
    class ReportRow < Struct.new(:account, :debit, :credit); end

    def initialize(start_date=nil, end_date=nil)
      @start_date = start_date || Time.now.beginning_of_month.to_date
      @end_date = end_date || Time.now.to_date

      raise "start_date must be before end_date" if @start_date > @end_date
    end

    def report
      @accounts = Account.all.select { |x| x.full_name =~ /^Expense/ }
      @report_rows = @accounts.collect do |account|
        r = ReportRow.new
        r.account = account

        transactions = account.transactions.where("transactions.date > ? AND transactions.date < ?", @start_date, @end_date)
        total_debit = transactions.collect(&:line_items).flatten.select{|x| x.account == account}.sum(&:debit).to_money
        total_credit = transactions.collect(&:line_items).flatten.select{|x| x.account == account}.sum(&:credit).to_money

        if total_debit > total_credit
          r.debit = total_debit - total_credit
          r.credit = 0.to_money
        else
          r.credit = total_credit - total_debit
          r.debit = 0.to_money
        end

        r
      end

      @report_rows
    end
  end
end
