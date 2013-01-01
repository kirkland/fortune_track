class AddDebitAndCreditTotalsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :debit_total_amount, :integer, default: 0, null: false
    add_column :accounts, :debit_total_code, :string, default: 'USD', null: false

    add_column :accounts, :credit_total_amount, :integer, default: 0, null: false
    add_column :accounts, :credit_total_code, :string, default: 'USD', null: false
  end
end
