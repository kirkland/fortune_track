class CreateAccountImports < ActiveRecord::Migration
  def change
    create_table :account_imports do |t|
      t.timestamps
      t.time :started_at
      t.boolean :successful
      t.text :importer_class_name
      t.text :data
    end
  end
end
