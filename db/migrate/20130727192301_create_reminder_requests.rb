class CreateReminderRequests < ActiveRecord::Migration
  def change
    create_table :reminder_requests do |t|
      t.string :referer
      t.string :tag
      t.string :email

      t.timestamps
    end
    add_index :reminder_requests, :email
  end
end
