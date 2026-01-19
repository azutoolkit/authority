class CreateUUID < CQL::Migration(1627600350)
  def up
    schema.exec %(CREATE EXTENSION IF NOT EXISTS "uuid-ossp";)
  end

  def down
    # UUID extension is typically not dropped
  end
end
