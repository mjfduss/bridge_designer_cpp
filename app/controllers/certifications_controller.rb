class CertificationsController < ApplicationController

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = session[:member_id] && Member.find(session[:member_id])
    @local_contest = @team.local_contests.first
  end

  def update
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    else
      team = Team.find(session[:team_id])
      if team.registration_category == 'e'
        redirect_to :controller => :captain_completions, :action => :edit, :id => team.captain.id
      else
        redirect_to :controller => :team_completions, :action => :edit, :id => team.id
      end
    end
  end
end
