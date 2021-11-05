class CreateUUID
  include Clear::Migration

  def change(direction)
    direction.up do
      execute %(CREATE EXTENSION IF NOT EXISTS "uuid-ossp";)
    end
  end
end
