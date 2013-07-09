class Admin::DocumentsController < Admin::ApplicationController
  def index
  end

  def new
    @document = Ckeditor::HtmlDocument.new
  end

  def create
    @document = Ckeditor::HtmlDocument.create do |doc|
      doc.text = params[:html_document][:text] || ''
    end
    unless @document
      flash.now[:alert] = 'Creation failed.'
      @document = Ckeditor::HtmlDocument.new
    end
    render 'new'
  end

  def edit
    @document = Ckeditor::HtmlDocument.find(params[:html_document][:id])
    unless @document
      flash.now[:alert] = 'Edit failed.'
      @document = Ckeditor::HtmlDocument.new
    end
  end

  def update
    @document = Ckeditor::HtmlDocument.find(params[:html_document][:id])
    if @document
      @document.text = params[:html_document][:text] || ''
      @document.save
    else
      flash.now[:alert] = 'Update failed.'
      @document = Ckeditor::HtmlDocument.new
    end
    render 'new'
  end

  # Action to return asset contents stored by paperclip_database.
  # This is slightly out of place here since it's more about paperclip than Ckeditor, but it's convenient.
  # Route is in the main config.
  def show
    asset = Ckeditor::Asset.find(params[:id])
    if asset
      style, basename = 'original', params[:style_basename]
      m = /^(\w+)_(\w+)$/.match(basename)
      if m
        style = m[1]
        # Not used: basename = m[2]
      end
      if asset.data_content_type == 'text/html'
        render :text => asset.data.file_contents(:original)
      else
        send_data asset.data.file_contents(style), :filename => asset.data_file_name, :type => asset.data_content_type
      end
    else
      render :nothing => true
    end
  end

  def destroy
    doc = Ckeditor::HtmlDocument.find(params[:html_document][:id])
    if doc
      doc.destroy
    else
      flash.now[:alert] = "Destroy failed."
    end
    @document = Ckeditor::HtmlDocument.new
    render 'new'
  end
end
