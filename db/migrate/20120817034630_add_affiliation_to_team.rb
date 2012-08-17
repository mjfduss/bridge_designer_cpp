class AddAffiliationToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :affiliation, :integer
  end
end
