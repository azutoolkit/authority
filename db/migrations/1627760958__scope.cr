class CreateScope
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :scopes do |t|
        t.column :scope, "varchar(80)", null: false
        t.column :is_default, "bool", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS scopes;"
    end
  end
end
