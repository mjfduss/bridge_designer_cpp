class Ckeditor::HtmlDocument < Ckeditor::Asset
  has_attached_file :data,
                    :storage => :database,
                    :database_table => 'ckeditor_assets_contents',
                    :url => '/ckeditor_assets/documents/:id/:filename'

  validates_attachment_size :data, :less_than => 1.megabytes
  validates_attachment_presence :data

  #Pseudo field implemented over Paperclip attachment
  def text
    f = data.file_for(:original)
    f ? f.file_contents : ''
  end

  def text=(val)
    self.data = val
    self.data_content_type = 'text/html'
  end

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
