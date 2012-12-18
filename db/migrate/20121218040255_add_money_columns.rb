class AddMoneyColumns < ActiveRecord::Migration
  def change
    add_column :line_items, :debit_amount, :integer, default: 0, null: false
    add_column :line_items, :debit_currency_code, :string, default: 'USD', null: false

    add_column :line_items, :credit_amount, :integer, default: 0, null: false
    add_column :line_items, :credit_currency_code, :string, default: 'USD', null: false

    remove_column :line_items, :debit_in_cents
    remove_column :line_items, :credit_in_cents
  end
end
