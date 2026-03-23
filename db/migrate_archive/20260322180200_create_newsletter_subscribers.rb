class CreateNewsletterSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletter_subscribers do |t|
      t.string :email, null: false
      t.integer :status, null: false, default: 0
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.datetime :last_emailed_at

      t.timestamps
    end

    add_index :newsletter_subscribers, :email, unique: true
    add_index :newsletter_subscribers, :status
  end
end
