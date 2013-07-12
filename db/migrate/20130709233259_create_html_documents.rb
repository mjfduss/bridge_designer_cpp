class CreateHtmlDocuments < ActiveRecord::Migration

  def up
    drop_table :assets
    create_table :html_documents do |t|
      t.string :subject, :null => false
      t.text :text, :null => false
      t.timestamps
    end
  end

  def down
    drop_table :html_documents
  end
end
