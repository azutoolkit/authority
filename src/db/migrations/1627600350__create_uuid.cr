class CreateUuid < CQL::Migration(1627600350_i64)
  def up
    schema.exec %(CREATE EXTENSION IF NOT EXISTS "uuid-ossp";)
  end

  def down
    # UUID extension is typically not dropped
  end
end
