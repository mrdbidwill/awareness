# frozen_string_literal: true

class SquashMigrationHistory < ActiveRecord::Migration[8.0]
  SQUASH_VERSION = "20260323150000"

  def up
    execute <<~SQL.squish
      DELETE FROM schema_migrations
      WHERE version <> '#{SQUASH_VERSION}'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Migration history squash cannot be reversed"
  end
end
