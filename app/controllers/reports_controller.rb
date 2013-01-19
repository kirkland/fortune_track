class ReportsController < ApplicationController
  def expense_report
    @start_date = params[:start_date].try(:to_date) || Date.today.beginning_of_month
    @end_date = params[:end_date].try(:to_date) || Date.today

    @report_rows = Report::ExpenseReport.new(@start_date, @end_date).run
  end
end
