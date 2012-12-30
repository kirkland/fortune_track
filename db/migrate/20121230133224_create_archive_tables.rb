class CreateArchiveTables < ActiveRecord::Migration
  def change
    create_table "archived_accounts", id: false, force: true do |t|
      t.integer  "id",                :null => false
      t.text     "name"
      t.text     "full_name"
      t.integer  "parent_account_id"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.string   "parser_class"
      t.integer  "sort_order"
      t.integer  "global_sort_order"
      t.datetime "deleted_at"
    end

    create_table "archived_line_items", :id => false, force: true do |t|
      t.integer  "id",                   :null => false
      t.integer  "transaction_id"
      t.integer  "account_id"
      t.integer  "debit_amount",         :null => false
      t.string   "debit_currency_code",  :null => false
      t.integer  "credit_amount",        :null => false
      t.string   "credit_currency_code", :null => false
      t.datetime "deleted_at"
    end

    create_table "archived_transactions", :id => false, force: true do |t|
      t.integer  "id",                       :null => false
      t.date     "date"
      t.text     "description"
      t.text     "unique_code"
      t.integer  "duplicate_transaction_id"
      t.datetime "deleted_at"
    end

    %w[archived_accounts archived_line_items archived_transactions].each do |t|
      execute "begin; alter table archived_accounts add column primary_id serial; update #{t} set primary_id = nextval('#{t}_primary_id_seq'); alter table #{t} add primary key(primary_id); commit"
    end
  end
end
