class CreateScoreboards < ActiveRecord::Migration
  def change
    create_table :scoreboards do |t|
      t.string :category, :limit => 1
      t.string :status, :limit => 1
      t.text :board

      t.timestamps
    end
  end
end
