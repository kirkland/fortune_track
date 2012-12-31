class AddSomeIndexes < ActiveRecord::Migration
  def change
    add_index 'line_items', ['transaction_id']
    add_index 'line_items', ['account_id']
  end
end
