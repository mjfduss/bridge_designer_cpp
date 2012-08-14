class CreateDesigns < ActiveRecord::Migration
  def change
    create_table :designs do |t|
      t.integer :team_id
      t.integer :score
      t.integer :sequence
      t.datetime :submitted
      t.integer :scenario
      t.text :bridge

      t.timestamps
    end
  end
end
