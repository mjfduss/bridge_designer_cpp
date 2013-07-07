class Admin::DocumentsController < Admin::ApplicationController
  def index
  end

  def new
    @document = Ckeditor::HtmlDocument.new
  end

  def create
    @document = Ckeditor::HtmlDocument.create do |doc|
      doc.data = StringIO.new(params[:html_document][:text] || '')
    end
    @document.text = @document.data.file_contents('original') if @document
    render 'new'
  end

  def edit
    @document = Ckeditor::HtmlDocument.find(params[:html_document][:id])
    @document.text = @document.data.file_contents('original') if @document
  end

  def update
    @document = Ckeditor::HtmlDocument.find(params[:html_document][:id])
    @document.data = StringIO.new(params[:html_document][:text] || '')
    @document.save
    @document.text = @document.data.file_contents('original') if @document
    render 'new'
  end

  # Action to return asset contents stored by paperclip_database.
  # This is slightly out of place here since it's more about paperclip than Ckeditor, but it's convenient.
  # Route is in the main config.
  def show
    asset = Ckeditor::Asset.find(params[:id])
    if asset && asset.data
      logger.debug "PARAMS=#{params.inspect}"
      style, basename = 'original', params[:style_basename]
      m = /^(\w+)_(\w+)$/.match(basename)
      if m
        style = m[1]
        basename = m[2]
      end
      #TODO Remove.
      logger.debug "REQUEST name=#{basename} style=#{style}"
      send_data asset.data.file_contents(style), :filename => asset.data_file_name, :type => asset.data_content_type
    else
      render :nothing => true
    end
  end

  def destroy
  end
end
