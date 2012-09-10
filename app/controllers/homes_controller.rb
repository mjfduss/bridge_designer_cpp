class HomesController < ApplicationController
  def edit
    @team = Team.find(params[:id])
    @design = Design.new
  end

  def update
  end
end
