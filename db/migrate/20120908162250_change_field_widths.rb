class ChangeFieldWidths < ActiveRecord::Migration
  def up
    change_column :members, :state, :string, :limit => 40
    change_column :members, :zip, :string, :limit => 16
    add_column :teams, :kind, :string, :limit => 1
  end

  def down
    change_column :members, :state, :string, :limit => 2
    change_column :members, :zip, :string, :limit => 9
    remove_column :teams, :kind
  end
end
