class VerificationsController < ApplicationController

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(session[:team_id])
    if params.has_key? :cancel
      c = @team.category == 'i' ? :team_completions : :captain_completions
      redirect_to :controller => c, :action => :edit
    else
      if @team.valid?
        redirect_to :controller => :homes, :action => :edit
      else
        flash[:error] = "Your registration is not valid. Sorry, you'll have to start again."
        redirect_to :controller => :sessions, :action => :new
      end
    end
  end
end
