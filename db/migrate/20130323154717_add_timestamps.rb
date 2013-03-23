class AddTimestamps < ActiveRecord::Migration
  def change
    add_column :transactions, :created_at, :timestamp
    add_column :transactions, :updated_at, :timestamp
    add_column :line_items, :created_at, :timestamp
    add_column :line_items, :updated_at, :timestamp
  end
end
