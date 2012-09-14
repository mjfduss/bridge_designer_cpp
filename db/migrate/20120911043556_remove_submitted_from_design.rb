class RemoveSubmittedFromDesign < ActiveRecord::Migration
  def up
    add_column :teams, :category, :string, :limit => 4
    add_column :teams, :reg_completed, :datetime
    remove_column :teams, :kind
    remove_column :designs, :submitted
    change_column :members, :country, :string, :limit => 40, :default => 'USA'
  end

  def down
    remove_column :teams, :category
    remove_column :teams, :reg_completed
    add_column :teams, :kind, :string, :limit => 4
    add_column :designs, :submitted, :datetime
    change_column :members, :country, :string, :limit => 40
  end
end
