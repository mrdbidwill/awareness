class CreateSubjects < ActiveRecord::Migration[8.0]
  DEFAULT_SUBJECTS = [
    "Mycology",
    "Mycology - Identification",
    "Mycology - Obfuscation",
    "Mushroom Character Discussion",
    "Tree - Identification",
    "Plant - Identification",
    "Website Organization",
    "Site Documentation",
    "Technical - Website Issues",
    "Other"
  ].freeze

  def up
    unless table_exists?(:subjects)
      create_table :subjects do |t|
        t.string :name, null: false
        t.string :slug, null: false
        t.timestamps
      end
    end

    add_index :subjects, :name, unique: true unless index_exists?(:subjects, :name)
    add_index :subjects, :slug, unique: true unless index_exists?(:subjects, :slug)

    DEFAULT_SUBJECTS.each do |name|
      execute <<~SQL.squish
        INSERT IGNORE INTO subjects (name, slug, created_at, updated_at)
        VALUES (#{quote(name)}, #{quote(name.parameterize)}, NOW(), NOW())
      SQL
    end
  end

  def down
    drop_table :subjects
  end
end
