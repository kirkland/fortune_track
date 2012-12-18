class AddParserToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :parser_class, :string
  end
end
