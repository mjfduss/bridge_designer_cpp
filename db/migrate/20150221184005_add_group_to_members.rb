class AddGroupToMembers < ActiveRecord::Migration
  def up
    add_column :members, :group_id, :integer
    Member.find_each do |member|
      member.group_id = member.team.group_id
      member.save!
    end
    remove_column :teams, :group_id
  end

  def down
    add_column :teams, :group_id, :integer
    Team.find_each do |team|
      team.group_id = team.captain.group_id
      team.save!
      raise ActiveRecord::IrreversibleMigration if team.members.pluck(:group_id).uniq.length > 1
    end
    remove_column :members, :group_id
  end
end
