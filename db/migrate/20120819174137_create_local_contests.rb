class CreateLocalContests < ActiveRecord::Migration
  def change
    create_table :local_contests do |t|
      t.string :code, :limit => 8
      t.string :description, :limit => 40
      t.string :poc_first_name, :limit => 40
      t.string :poc_middle_initial, :limit => 1
      t.string :poc_last_name, :limit => 40
      t.string :poc_position, :limit => 40
      t.string :organization, :limit => 40
      t.string :city, :limit => 40
      t.string :state, :limit => 40
      t.string :zip, :limit => 9
      t.string :phone, :limit => 16
      t.string :link, :limit => 40

      t.timestamps
    end
  end
end
