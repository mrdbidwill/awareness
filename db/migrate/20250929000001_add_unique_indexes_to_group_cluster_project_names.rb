class AddUniqueIndexesToGroupClusterProjectNames < ActiveRecord::Migration[8.0]
  def change
    # Unique per user
    add_index :all_groups, [:user_id, :name], unique: true, name: "index_all_groups_on_user_id_and_lower_name", order: { name: :asc }
    add_index :clusters,   [:user_id, :name], unique: true, name: "index_clusters_on_user_id_and_lower_name", order: { name: :asc }

    # Unique globally
    add_index :projects, :name, unique: true, name: "index_projects_on_name_unique"
  end
end