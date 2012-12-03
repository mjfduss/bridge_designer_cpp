class VerificationsController < ApplicationController
  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(params[:id])
    if params.has_key? :cancel
      c = @team.category == 'i' ? :team_completions : :captain_completions
      redirect_to :controller => c, :action => :edit, :id => session[:captain_id]
    else
      if @team.valid?
        redirect_to :controller => :homes, :action => :edit, :id => params[:id]
      else
        flash[:error] = "Your registration is not valid. Sorry, you'll have to start again."
        redirect_do :controller => :sessions, :action => :new
      end
    end
  end
end
