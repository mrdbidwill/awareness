class NormalizeArticleSubjects < ActiveRecord::Migration[8.0]
  def up
    add_reference :articles, :subject, foreign_key: true, index: true unless column_exists?(:articles, :subject_id)

    if column_exists?(:articles, :subject)
      say_with_time "Backfilling articles.subject_id from legacy articles.subject values" do
        legacy_subjects = select_values(<<~SQL.squish)
          SELECT DISTINCT subject
          FROM articles
          WHERE subject IS NOT NULL AND subject <> ''
        SQL

        legacy_subjects.each do |name|
          subject_id = subject_id_for_name(name)

          execute <<~SQL.squish
            UPDATE articles
            SET subject_id = #{subject_id}
            WHERE subject = #{quote(name)}
          SQL
        end
      end

      remove_column :articles, :subject, :string
    end
  end

  def down
    add_column :articles, :subject, :string
    add_index :articles, :subject

    execute <<~SQL.squish
      UPDATE articles
      INNER JOIN subjects ON subjects.id = articles.subject_id
      SET articles.subject = subjects.name
    SQL

    remove_reference :articles, :subject, foreign_key: true, index: true
  end

  private

  def subject_id_for_name(name)
    existing_id = select_value("SELECT id FROM subjects WHERE name = #{quote(name)} LIMIT 1")
    return existing_id.to_i if existing_id.present?

    slug = unique_slug_for(name)
    execute <<~SQL.squish
      INSERT INTO subjects (name, slug, created_at, updated_at)
      VALUES (#{quote(name)}, #{quote(slug)}, NOW(), NOW())
    SQL

    select_value("SELECT id FROM subjects WHERE name = #{quote(name)} LIMIT 1").to_i
  end

  def unique_slug_for(name)
    base = name.to_s.parameterize.presence || "subject"
    slug = base
    counter = 2

    while select_value("SELECT 1 FROM subjects WHERE slug = #{quote(slug)} LIMIT 1").present?
      slug = "#{base}-#{counter}"
      counter += 1
    end

    slug
  end
end
