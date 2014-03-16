class AddCertificatesCountToLocalContests < ActiveRecord::Migration
  def change
    add_column :local_contests, :certificates_count, :integer, :null => false, :default => 0
  end
end
