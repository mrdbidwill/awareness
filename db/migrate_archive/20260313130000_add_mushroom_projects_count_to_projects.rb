class AddMushroomProjectsCountToProjects < ActiveRecord::Migration[8.0]
  def up
    add_column :projects, :mushroom_projects_count, :integer, default: 0, null: false

    execute <<~SQL.squish
      UPDATE projects
      SET mushroom_projects_count = (
        SELECT COUNT(*)
        FROM mushroom_projects
        WHERE mushroom_projects.project_id = projects.id
      )
    SQL
  end

  def down
    remove_column :projects, :mushroom_projects_count
  end
end
