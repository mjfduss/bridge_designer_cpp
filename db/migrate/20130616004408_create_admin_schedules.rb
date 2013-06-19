class CreateAdminSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :name, :limit => 40, :null => false
      t.boolean :active, :null => false
      t.boolean :closed, :null => false
      t.text :message, :null => false
      t.datetime :start_quals_prereg, :null => false
      t.datetime :start_quals, :null => false
      t.datetime :end_quals, :null => false
      t.boolean :quals_tally_complete, :null => false
      t.datetime :start_semis_prereg, :null => false
      t.datetime :start_semis, :null => false
      t.datetime :end_semis, :null => false

      t.timestamps
    end
  end
end
