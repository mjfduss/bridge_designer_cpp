class HomesController < ApplicationController
  def edit
    @team = Team.find(params[:id])
    @design = Design.new
  end

  def update
    design = params[:design]
    @design = Design.create(:team_id => params[:id],
                            :score => 1000,
                            :sequence => 1,
                            :scenario => 1234,
                            :bridge => design[:bridge].read)
    @team = Team.find(params[:id])
    if @design
      render 'edit'
    else
      flash[:alert] = 'Save failed'
      render 'edit'
    end
  end
end
