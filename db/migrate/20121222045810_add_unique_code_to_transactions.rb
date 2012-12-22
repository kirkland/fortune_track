class AddUniqueCodeToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :unique_code, :text
  end
end
