class AddEnvironmentTable < ActiveRecord::Migration
  def change
    create_table :environments do |t|
      # Tag is used for filtering, e.g. "prequals"
      t.string :tag, :limit => 40
      # Key value pairs form property lists.
      t.string :key, :limit => 16
      t.string :value, :limit => 255

      t.timestamps
    end
  end
end
