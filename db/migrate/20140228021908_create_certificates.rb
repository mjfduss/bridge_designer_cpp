class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :team_id, :null => false
      t.integer :local_contest_id
      t.integer :design_id, :null => false
      t.integer :standing, :null => false
      t.integer :basis, :null => false
      t.integer :group_id
      t.integer :group_standing
      t.integer :group_basis
      t.date :awarded_on, :null => false

      t.timestamps
    end
    add_index :certificates, :team_id
    add_index :certificates, :local_contest_id
  end
end
