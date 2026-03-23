# frozen_string_literal: true

class AddReferencesAndRemoveTemporaryInvitations < ActiveRecord::Migration[8.0]
  def up
    create_table :references do |t|
      t.string :name, null: false
      t.string :author
      t.text :description
      t.date :publish_date

      t.timestamps
    end

    add_index :references, :name
    add_index :references, :publish_date

    drop_table :invitation_tokens, if_exists: true

    remove_column :users, :temporary_admin, :boolean, if_exists: true
    remove_column :users, :admin_expires_at, :datetime, if_exists: true
  end

  def down
    add_column :users, :temporary_admin, :boolean, default: false, null: false unless column_exists?(:users, :temporary_admin)
    add_column :users, :admin_expires_at, :datetime unless column_exists?(:users, :admin_expires_at)

    create_table :invitation_tokens do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :used_at
      t.datetime :admin_expires_at, null: false
      t.integer :created_by_user_id, null: false
      t.integer :invited_user_id
      t.timestamps
    end unless table_exists?(:invitation_tokens)

    add_index :invitation_tokens, :token, unique: true unless index_exists?(:invitation_tokens, :token)
    add_index :invitation_tokens, :created_by_user_id unless index_exists?(:invitation_tokens, :created_by_user_id)
    add_index :invitation_tokens, :email unless index_exists?(:invitation_tokens, :email)
    add_index :invitation_tokens, :invited_user_id unless index_exists?(:invitation_tokens, :invited_user_id)

    drop_table :references, if_exists: true
  end
end
