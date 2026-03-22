class CreateTrustedDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :trusted_devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_token, null: false
      t.string :device_fingerprint, null: false
      t.datetime :trusted_at, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :trusted_devices, :device_token, unique: true
    add_index :trusted_devices, [:user_id, :device_fingerprint]
  end
end
