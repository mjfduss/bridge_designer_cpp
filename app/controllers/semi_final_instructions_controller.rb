class SemiFinalInstructionsController < ApplicationController

  before_filter :require_login

  def edit
    @team = Team.find(session[:team_id])
  end

  def update
    @team = Team.find(session[:team_id])
    if @team.status != '2'
      kill_session 'Your Team has no Semi-Finals Home Page!'
    elsif params[:semis_home]
      session[:is_semis_session] = true
      redirect_to :controller => :homes, :action => :edit
    elsif params[:team_home]
      redirect_to :controller => :verifications, :action => :edit
    else
      kill_session 'Your selection of home page could not be processed.'
    end
  end

end
