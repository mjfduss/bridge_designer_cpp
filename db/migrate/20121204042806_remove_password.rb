class RemovePassword < ActiveRecord::Migration
  def up
    remove_column :administrators, :password
    change_column :administrators, :password_digest, :string, :limit => 60
    change_column :administrators, :name, :string, :limit => 16
  end

  def down
    add_column :administrators, :password, :string
    change_column :administrators, :password_digest, :string, :limit => nil
    change_column :administrators, :name, :string, :limit => nil
  end
end
