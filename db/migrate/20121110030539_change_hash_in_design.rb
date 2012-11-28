class ChangeHashInDesign < ActiveRecord::Migration
  def up
    remove_column :designs, :hash
    add_column :designs, :hash_string, :string, { :limit => 40 }
  end

  def down
    remove_column :designs, :hash_string
    add_column :designs, :hash, :string, { :limit => 40 }
  end
end
