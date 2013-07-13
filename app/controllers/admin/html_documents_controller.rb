class Admin::HtmlDocumentsController < Admin::ApplicationController

  def edit
    @edited_document = HtmlDocument.new
    @documents = HtmlDocument.all
  end

  def update
    selected = params[:select]
    ids = params[:ids]
    ids = ids.split(',') if ids

    if params.nonblank? :get
      if selected.blank?
        @edited_document = HtmlDocument.new
        flash.now[:alert] = 'New document ready to edit.'
      else
        @edited_document = HtmlDocument.find(selected[0].to_i)
        flash.now[:alert] = 'Selected document ready to edit.'
      end
    elsif params.nonblank? :delete
      if selected.blank?
        flash.now[:alert] = 'No documents were selected for deletion.'
      else
        HtmlDocument.destroy(selected) # Destroy sets foreign keys in teams to null
        flash.now[:alert] = 'Selected documents were deleted.'
      end
      @edited_document = HtmlDocument.new
    elsif params.nonblank? :query
      @documents = HtmlDocument.qbe(params[:html_document])
      @edited_document = HtmlDocument.new(params[:html_document])
      flash.now[:alert] = 'Query results are shown below.'
    else # Nothing means submission by "save" button on editor control.
      id = params[:html_document][:id]
      if id.blank?
        @edited_document = HtmlDocument.create(params[:html_document])
        if @edited_document.valid?
          ids << @edited_document.id if ids
          flash.now[:alert] = "New document '#{params[:html_document][:subject]}' was created."
        else
          flash.now[:alert] = "New document could not be created."
        end
      else
        @edited_document = HtmlDocument.find(id.to_i)
        @edited_document.update_attributes(params[:html_document])
        flash.now[:alert] = "Document '#{params[:html_document][:subject]}' was updated."
      end
    end
    @documents ||= ids ? HtmlDocument.where(:id => ids) : HtmlDocument.all
    render :action => :edit
  end

  # Action to return asset contents stored by paperclip_database.
  # This is slightly out of place here since it's more about paperclip than Ckeditor, but it's convenient.
  # Route is in the main config.
  def show
    asset = Ckeditor::Asset.find(params[:id])
    if asset
      style, basename = 'original', params[:style_basename]
      m = /^(\w+?)_(\w+)$/.match(basename)
      if m
        style = m[1]
        # Not used: basename = m[2]
      end
      send_data asset.data.file_contents(style), :filename => asset.data_file_name, :type => asset.data_content_type
    else
      render :nothing => true
    end
  end

end
