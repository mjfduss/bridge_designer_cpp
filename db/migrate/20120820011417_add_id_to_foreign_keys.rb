class AddIdToForeignKeys < ActiveRecord::Migration
  def up
    remove_column :affiliations, :team
    remove_column :affiliations, :local_contest
    add_column :affiliations, :team_id, :integer
    add_column :affiliations, :local_contest_id, :integer
  end

  def down
    add_column :affiliations, :team, :integer
    add_column :affiliations, :local_contest, :integer
    remove_column :affiliations, :team_id
    remove_column :affiliations, :local_contest_id
  end
end
