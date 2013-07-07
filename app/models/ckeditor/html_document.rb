class Ckeditor::HtmlDocument < Ckeditor::Asset
  has_attached_file :data,
                    :storage => :database,
                    :database_table => 'ckeditor_assets_contents',
                    :url => '/ckeditor_assets/documents/:id/:filename'

  validates_attachment_size :data, :less_than => 1.megabytes
  validates_attachment_presence :data

  attr_accessor :text

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
