class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name, :limit => 40
      t.string :middle_initial, :limit => 1
      t.string :last_name, :limit => 40
      t.string :category, :limit => 1
      t.integer :age
      t.integer :grade
      t.string :phone, :limit => 16
      t.string :street, :limit => 40
      t.string :city, :limit => 40
      t.string :state, :limit => 2
      t.string :zip, :limit => 9
      t.string :school, :limit => 40
      t.string :school_city, :limit => 40
      t.string :sex, :limit => 1
      t.string :hispanic, :limit => 1
      t.string :race, :limit => 1

      t.timestamps
    end
  end
end
