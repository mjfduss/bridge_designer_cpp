class TeamCompletionsController < ApplicationController

  def edit
    @team = Team.find(params[:id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(params[:id])
    if params.has_key? :cancel
      redirect_to :controller => :captain_completions, :action => :edit, :id => session[:captain_id]
    else
      @team.completed = true
      if @team.update_attributes(params[:team])
        redirect_to :controller => :homes, :action => :edit, :id => params[:id]
      else
        render 'edit'
      end
    end
  end
end
