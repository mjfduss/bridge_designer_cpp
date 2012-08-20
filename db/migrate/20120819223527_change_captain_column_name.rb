class ChangeCaptainColumnName < ActiveRecord::Migration
  def up
    remove_column :teams, :captain
    remove_column :teams, :affiliation
    remove_column :teams, :group
    add_column :teams, :captain_id, :integer
  end

  def down
    add_column :teams, :captain, :integer
    add_column :teams, :affiliation, :integer
    add_column :teams, :group, :integer
    remove_column :teams, :captain_id
  end
end
