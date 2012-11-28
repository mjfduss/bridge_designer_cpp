class CreateSequenceNumbers < ActiveRecord::Migration
  def change
    create_table :sequence_numbers do |t|
      t.string :tag, :limit => 8, :null => false
      t.integer :value, :null => false, :default => 0

      t.timestamps
    end
  end
end
