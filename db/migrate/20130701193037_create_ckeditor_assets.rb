class CreateCkeditorAssets < ActiveRecord::Migration
  def self.up
    create_table :ckeditor_assets do |t|
      t.string  :data_file_name, :null => false
      t.string  :data_content_type
      t.integer :data_file_size
      
      t.integer :assetable_id
      t.string  :assetable_type, :limit => 30
      t.string  :type, :limit => 30

      t.integer :width
      t.integer :height

      t.timestamps
    end
    
    add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"
    add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"

    create_table :ckeditor_assets_contents do |t|
      t.integer    :ckeditor_asset_id
      t.string     :style
      t.binary     :file_contents
    end
    add_index "ckeditor_assets_contents", ["ckeditor_asset_id"]

  end

  def self.down
    drop_table :ckeditor_assets
    drop_table :ckeditor_assets_contents
  end
end
