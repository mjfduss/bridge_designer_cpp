class ChangeLinkInLocalContests < ActiveRecord::Migration
  def up
    change_column :local_contests, :link, :string, :limit => 80
  end

  def down
    change_column :local_contests, :link, :string, :limit => 40
  end
end
