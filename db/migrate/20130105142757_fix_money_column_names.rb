class FixMoneyColumnNames < ActiveRecord::Migration
  def change
    rename_column :accounts, :debit_total_code, :debit_total_currency_code
    rename_column :accounts, :credit_total_code, :credit_total_currency_code
  end
end
