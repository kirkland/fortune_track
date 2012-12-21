class AddSortOrderToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :sort_order, :integer
  end
end
