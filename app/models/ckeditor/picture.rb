class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    :storage => :database,
                    :database_table => 'ckeditor_assets_contents',
                    :url  => "/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                    :styles => { :content => '800>', :thumb => '118x100#' }

  validates_attachment_size :data, :less_than => 2.megabytes
  validates_attachment_presence :data

  def url_content
    url(:content)
  end
end
