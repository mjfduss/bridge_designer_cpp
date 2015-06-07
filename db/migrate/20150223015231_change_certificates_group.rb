class ChangeCertificatesGroup < ActiveRecord::Migration
  def up
    add_column :certificates, :group_info, :text
    Certificate.find_each do |c|
      c.group_info = c.group_id ? [ Certificate::PerGroupInfo.new(c.group_id, c.group_standing, c.group_basis) ] : nil
      c.save!
    end
    remove_column :certificates, :group_id
    remove_column :certificates, :group_basis
    remove_column :certificates, :group_standing
  end

  def down
    raise ActiveRecord::IrreversibleMigration unless
    remove_column :certificates, :group_info
    add_column :certificates, :group_id, :integer
    add_column :certificates, :group_basis, :integer
    add_column :certificates, :group_standing, :integer
  end
end
