class AddStatusToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :status, :string, :limit => 1, :null => false, :default => '-'
  end
end
