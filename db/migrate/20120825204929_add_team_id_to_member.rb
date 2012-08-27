class AddTeamIdToMember < ActiveRecord::Migration

  def up
    add_column :members, :team_id, :integer
  end

  def down
    remove_column :members, :team_id
  end

end
