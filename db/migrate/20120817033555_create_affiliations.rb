class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.integer :team
      t.integer :local_contest

      t.timestamps
    end
  end
end
