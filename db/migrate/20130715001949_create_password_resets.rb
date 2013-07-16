class CreatePasswordResets < ActiveRecord::Migration
  def change
    create_table :password_resets do |t|
      t.string :key
      t.integer :team_id, :null => false

      t.timestamps
    end
    add_index :password_resets, :key, :unique => true
    add_index :password_resets, :team_id, :unique => true
    add_index :teams, :email
  end
end
