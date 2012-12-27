class AddGlobalSortOrderToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :global_sort_order, :integer
  end
end
