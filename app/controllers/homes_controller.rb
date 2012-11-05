class HomesController < ApplicationController
  def edit
    @team = Team.find(params[:id])
    @design = Design.new
  end

  def update
    design_upload = params[:design]
    bridge = design_upload[:bridge].read
    WPBDC.endecrypt(bridge)
    analysis = WPBDC.analyze(bridge)
    case analysis[:status]
      when WPBDC::BRIDGE_WRONGVERSION

      when WPBDC::BRIDGE_MALFORMED
      when WPBDC::BRIDGE_FAILEDTEST
      when WPBDC::BRIDGE_OK
    end
    @design = Design.create(:team_id => params[:id],
                            :score => 1000,
                            :sequence => 1,
                            :scenario => 1234,
                            :bridge => bridge)
    @team = Team.find(params[:id])
    if @design
      render 'edit'
    else
      flash[:alert] = 'Save failed'
      render 'edit'
    end
  end
end
