# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121231144820) do

  create_table "accounts", :force => true do |t|
    t.text     "name"
    t.text     "full_name"
    t.integer  "parent_account_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "sort_order"
    t.integer  "global_sort_order"
  end

  create_table "line_items", :force => true do |t|
    t.integer "transaction_id"
    t.integer "account_id"
    t.integer "debit_amount",         :default => 0,     :null => false
    t.string  "debit_currency_code",  :default => "USD", :null => false
    t.integer "credit_amount",        :default => 0,     :null => false
    t.string  "credit_currency_code", :default => "USD", :null => false
  end

  add_index "line_items", ["account_id"], :name => "index_line_items_on_account_id"
  add_index "line_items", ["transaction_id"], :name => "index_line_items_on_transaction_id"

  create_table "transactions", :force => true do |t|
    t.date    "date"
    t.text    "description"
    t.text    "unique_code"
    t.integer "duplicate_transaction_id"
  end

end
