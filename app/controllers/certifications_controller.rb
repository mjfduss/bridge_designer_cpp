class CertificationsController < ApplicationController

  def new
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = session[:member_id] && Member.find(session[:member_id])
    @local_contest = @team.local_contests.first
  end

  def create
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    else
      redirect_to :controller => :captain_completions, :action => :new
    end
  end
end
