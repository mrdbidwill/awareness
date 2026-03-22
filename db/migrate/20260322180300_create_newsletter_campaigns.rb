class CreateNewsletterCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletter_campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject, null: false
      t.text :body, null: false
      t.string :from_email
      t.integer :status, null: false, default: 0
      t.integer :recipients_count, null: false, default: 0
      t.integer :delivered_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.datetime :queued_at
      t.datetime :started_at
      t.datetime :sent_at
      t.string :last_error

      t.timestamps
    end

    add_index :newsletter_campaigns, :status
    add_index :newsletter_campaigns, :sent_at
  end
end
