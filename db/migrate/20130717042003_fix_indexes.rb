class FixIndexes < ActiveRecord::Migration
  def up
    remove_index :designs, :name => 'index_designs_on_score_and_sequence'
    add_index :designs, %w{team_id score sequence}
    add_index :bests, :team_id
  end

  def down
    add_index :designs, %w{score sequence}
    remove_index :designs, :name => 'index_designs_on_team_id_and_score_and_sequence'
    remove_index :bests, :column => :team_id
  end
end
