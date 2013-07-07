class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :name
      t.string :type
      t.references :assetable, :polymorphic => true
      t.text :content
      t.string :content_type
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
