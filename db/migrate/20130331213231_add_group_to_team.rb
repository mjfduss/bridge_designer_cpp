class AddGroupToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :group_id, :integer, :null => true
  end
end
