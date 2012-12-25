class ReportsController < ApplicationController
  def expense_report
    @report_rows = Reports::ExpenseReport.new(params[:start_date].try(:to_date),
      params[:end_date].try(:to_date)).report
  end
end
