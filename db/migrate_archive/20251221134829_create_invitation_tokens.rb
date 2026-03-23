class CreateInvitationTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :invitation_tokens do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :used_at
      t.datetime :admin_expires_at, null: false
      t.integer :created_by_user_id, null: false
      t.integer :invited_user_id

      t.timestamps
    end
    add_index :invitation_tokens, :token, unique: true
    add_index :invitation_tokens, :created_by_user_id
    add_index :invitation_tokens, :email
    add_index :invitation_tokens, :invited_user_id
  end
end
