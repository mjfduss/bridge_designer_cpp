class CreateParents < ActiveRecord::Migration
  def change
    create_table :parents do |t|
      t.string :first_name, :limit => 40
      t.string :middle_initial, :limit => 1
      t.string :last_name, :limit => 40
      t.string :email, :limit => 40
      t.integer :member_id

      t.timestamps
    end
  end
end
