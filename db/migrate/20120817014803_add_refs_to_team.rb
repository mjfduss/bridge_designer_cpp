class AddRefsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :captain, :integer
    add_column :teams, :group, :integer
  end
end
