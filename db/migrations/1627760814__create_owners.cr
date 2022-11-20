class CreateOwners
  include Clear::Migration

  def change(dir)
    dir.up do
      create_table :owners, id: :uuid do |t|
        t.column :username, "varchar(80)", null: false, index: true, unique: true
        t.column :encrypted_password, "varchar(80)", null: false
        t.column :first_name, "varchar(80)", null: false
        t.column :last_name, "varchar(80)", null: false
        t.column :email, "varchar(80)", null: false
        t.column :email_verified, "bool", null: false
        t.column :scope, "varchar(4000)", null: false

        t.timestamps
      end
    end

    dir.down do
      execute "DROP TABLE IF EXISTS owners;"
    end
  end
end
