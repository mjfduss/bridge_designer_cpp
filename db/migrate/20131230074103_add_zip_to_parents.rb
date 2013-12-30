class AddZipToParents < ActiveRecord::Migration
  def change
    add_column :parents, :zip, :string, :limit => 16
  end
end
