class ChangeSchoolToRegState < ActiveRecord::Migration
  def up
    remove_column :members, :school_state
    add_column :members, :reg_state, :string, :limit => 2
  end

  def down
    add_column :members, :school_state, :limit => 2
    remove_column :members, :reg_state
  end
end
