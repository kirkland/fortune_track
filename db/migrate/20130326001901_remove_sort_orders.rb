class RemoveSortOrders < ActiveRecord::Migration
  def up
    remove_column :accounts, :sort_order
    remove_column :accounts, :global_sort_order
  end

  def down
  end
end
