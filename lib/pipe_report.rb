r = Report::ExpenseReport.new(Date.new(2013,1,1), Date.new(2013,3,31)).run

def add_to_report(row)
  account = row.account.full_name
  debit = (row.debit - row.credit).format
  self_debit = (row.self_debit - row.self_credit).format
  @output_rows << [account, debit, self_debit].join('|')

  row.child_rows.each do |row|
    add_to_report(row)
  end
end

@output_rows = []

r.report_rows.each do |row|
  add_to_report(row)
end

@output_rows.each do |row|
  puts row
end; nil
