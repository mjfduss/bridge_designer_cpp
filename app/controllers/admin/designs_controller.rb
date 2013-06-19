class Admin::DesignsController < Admin::ApplicationController

  layout 'admin/analysis'

  caches_page :show

  SKETCH_WIDTH = 90
  SKETCH_HEIGHT = 60

  def show
    @design = Design.find(params[:id])
    if @design
      respond_to do |format|
        format.png { send_data WPBDC.sketch(@design.bridge, SKETCH_WIDTH, SKETCH_HEIGHT)[:image], :type => 'image/png', :disposition => 'inline' }
        format.bdc { send_data WPBDC.endecrypt(String.new @design.bridge) }
        format.html  # default template, which provides analysis table
      end
    else
      render :nothing => true
    end
  end
end
