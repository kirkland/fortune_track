class AddDuplicateTransactionIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :duplicate_transaction_id, :integer
  end
end
