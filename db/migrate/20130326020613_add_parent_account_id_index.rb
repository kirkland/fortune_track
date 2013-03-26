class AddParentAccountIdIndex < ActiveRecord::Migration
  def up
    add_index :accounts, :parent_account_id
  end

  def down
    remove_index :accounts, :parent_account_id
  end
end
