class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :name
      t.integer :parent_account_id

      t.timestamps
    end

    create_table :transactions do |t|
      t.date :date
      t.text :description
    end

    create_table :line_items do |t|
      t.integer :transaction_id
      t.integer :account_id
      t.integer :credit_in_cents
      t.integer :debit_in_cents
    end
  end
end
