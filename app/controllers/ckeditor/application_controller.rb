class Ckeditor::ApplicationController < Admin::ApplicationController
  layout 'ckeditor/application'
  respond_to :html, :json

  before_filter :find_asset, :only => [:destroy]
  before_filter :ckeditor_authorize!
  before_filter :authorize_resource

  protected
    
    def respond_with_asset(asset)
      file = params[:CKEditor].blank? ? params[:qqfile] : params[:upload]
      np =  Ckeditor::Http.normalize_param(file, request)
      #TODO Remove.
      begin
        asset.data = np
      rescue => e
        logger.error e.message
        logger.error e.backtrace.join("\n")
        raise
      end

      callback = ckeditor_before_create_asset(asset)

      if callback && asset.save
        body = params[:CKEditor].blank? ? asset.to_json(:only=>[:id, :type]) : %Q"<script type='text/javascript'>
          window.parent.CKEDITOR.tools.callFunction(#{params[:CKEditorFuncNum]}, '#{Ckeditor::Utils.escape_single_quotes(asset.url_content)}');
        </script>"
        
        render :text => body
      else
        render :nothing => true
      end
    end
end
