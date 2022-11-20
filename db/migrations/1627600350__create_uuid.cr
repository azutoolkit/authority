class CreateUUID
  include Clear::Migration

  def change(dir)
    dir.up do
      execute %(CREATE EXTENSION IF NOT EXISTS "uuid-ossp";)
    end
  end
end
