class VerificationsController < ApplicationController
  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(params[:id])
    if params.has_key? :cancel
    else
      if @team.isValid?
        redirect_to :controller => :homes, :action => :edit, :id => params[:id]
      end
    end
  end
end
