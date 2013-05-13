class Admin::DesignsController < Admin::ApplicationController

  layout 'admin/analysis'

  SKETCH_WIDTH = 120
  SKETCH_HEIGHT = 80

  def show
    @design = Design.find(params[:id])
    if @design
      respond_to do |format|
        format.png { send_data WPBDC.sketch(@design.bridge, SKETCH_WIDTH, SKETCH_HEIGHT)[:image], :type => 'image/png', :disposition => 'inline' }
        format.bdc { send_data WPBDC.endecrypt(String.new @design.bridge) }
        format.html  # default template
      end
    else
      render :nothing => true
    end
  end
end
