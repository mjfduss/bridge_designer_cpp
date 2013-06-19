class DropEnvironment < ActiveRecord::Migration
  def up
    #drop_table :environments
    change_column :schedules, :active, :boolean, :null => false, :default => false
  end

  def down
    change_column :schedules, :active, :boolean, :null => false
  end
end
