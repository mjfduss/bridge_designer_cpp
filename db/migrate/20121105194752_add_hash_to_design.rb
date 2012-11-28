class AddHashToDesign < ActiveRecord::Migration
  def change
    # Must be twice HASH_SIZE for hex encoding.
    add_column :designs, :hash, :string, { :limit => 40 }
  end
end
