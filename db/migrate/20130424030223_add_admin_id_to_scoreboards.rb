class AddAdminIdToScoreboards < ActiveRecord::Migration
  def change
    add_column :scoreboards, :admin_id, :integer, :null => false
  end
end
