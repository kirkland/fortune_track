class RemoveAccountParserColumn < ActiveRecord::Migration
  def up
    remove_column :accounts, :parser_class
  end

  def down
    add_column :accounts, :parser_class, :string
  end
end
