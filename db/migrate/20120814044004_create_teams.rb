class CreateTeams < ActiveRecord::Migration

  def change
    create_table :teams do |t|
      t.string :name, :limit => 32
      t.string :name_key, :limit => 32
      t.string :email, :limit => 40
      t.string :password_digest => 16
      t.string :local_contest => 16
      t.integer :submits 
      t.integer :improves
      t.string :ip => 15

      t.timestamps

    end
  end

end
