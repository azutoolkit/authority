# Migration to create settings table for system configuration
class CreateSettings < CQL::Migration(1768941100)
  def up
    schema.create :settings, if_not_exists: true do
      primary_key :id, type: :uuid
      column :key, type: :text, null: false
      column :value, type: :text
      column :category, type: :text, null: false
      column :description, type: :text
      column :updated_at, type: :timestamp, null: false
      column :updated_by, type: :text

      index [:key], unique: true
      index [:category]
    end
  end

  def down
    schema.drop :settings, if_exists: true
  end
end
