class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.string :name
      t.string :password
      t.string :password_digest

      t.timestamps
    end
  end
end
