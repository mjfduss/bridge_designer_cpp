class ChangeIntFieldsToNotNull < ActiveRecord::Migration
  def up
    change_column :affiliations, :team_id,          :integer, :null => false, :default => 0
    change_column :affiliations, :local_contest_id, :integer, :null => false, :default => 0
    change_column :designs, :team_id,               :integer, :null => false, :default => 0
    change_column :designs, :score,                 :integer, :null => false, :default => 0
    change_column :designs, :sequence,              :integer, :null => false, :default => 0
    change_column :designs, :scenario,              :string,  :null => false, :default => '', :limit => 10
    change_column :members, :team_id,               :integer, :null => false, :default => 0
    change_column :members, :rank,                  :integer, :null => false, :default => 0
    change_column :members, :age,                   :integer, :null => false, :default => 0
    change_column :members, :grade,                 :integer, :null => false, :default => 0
    change_column :teams,   :submits,               :integer, :null => false, :default => 0
    change_column :teams,   :improves,              :integer, :null => false, :default => 0

  end

  def down
    change_column :affiliations, :team_id,          :integer, :null => true
    change_column :affiliations, :local_contest_id, :integer, :null => true
    change_column :designs, :team_id,               :integer, :null => true
    change_column :designs, :score,                 :integer, :null => true
    change_column :designs, :sequence,              :integer, :null => true
    change_column :designs, :scenario,              :integer, :null => true
    change_column :members, :team_id,               :integer, :null => true
    change_column :members, :rank,                  :integer, :null => true
    change_column :members, :age,                   :integer, :null => true
    change_column :members, :grade,                 :integer, :null => true
    change_column :teams,   :submits,               :integer, :null => true
    change_column :teams,   :improves,              :integer, :null => true
  end
end
