class ChangeScoreTo64BitInt < ActiveRecord::Migration
  def up
    change_column :designs, :score, :integer, :limit => 8
    change_column :bests, :score, :integer, :limit => 8
  end

  def down
    change_column :designs, :score, :integer
    change_column :bests, :score, :integer
  end
end
