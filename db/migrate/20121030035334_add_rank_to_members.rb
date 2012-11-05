class AddRankToMembers < ActiveRecord::Migration
  def up
    add_column :members, :rank, :integer
    remove_column :teams, :captain_id
  end
  def down
    remove_column :members, :rank
    add_column :teams, :captain_id, :integer
  end
end
