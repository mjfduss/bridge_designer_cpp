class CreateLocalScoreboards < ActiveRecord::Migration
  def change
    create_table :local_scoreboards do |t|
      t.string :code
      t.integer :page
      t.text :board

      t.timestamps
    end
    add_index :local_scoreboards, %w{code page}
  end
end
