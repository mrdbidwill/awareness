class AddOtpBackupCodesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp_backup_codes, :json, null: true
  end
end
