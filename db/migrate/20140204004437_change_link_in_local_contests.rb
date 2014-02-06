class ChangeLinkInLocalContests < ActiveRecord::Migration
  def up
    change_column :local_contests, :link, :string, :limit => 80
    change_column :teams, :email, :string, :limit => 80
    change_column :parents, :email, :string, :limit => 80
  end

  def down
    change_column :local_contests, :link, :string, :limit => 40
    change_column :teams, :email, :string, :limit => 40
    change_column :parents, :email, :string, :limit => 40
  end
end
