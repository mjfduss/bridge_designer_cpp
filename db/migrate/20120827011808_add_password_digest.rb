class AddPasswordDigest < ActiveRecord::Migration
  def up
    add_column :teams, :password_digest, :string, :limit => 60
  end

  def down
    remove_column :teams, :password_digest
  end
end
