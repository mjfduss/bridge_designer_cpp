class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :description, :limit => 40

      t.timestamps
    end
  end
end
