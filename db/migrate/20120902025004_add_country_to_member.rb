class AddCountryToMember < ActiveRecord::Migration
  def change
    add_column :members, :country, :string, { :limit => 40 }
  end
end
