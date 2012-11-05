class SessionsController < ApplicationController

  skip_before_filter :require_valid_session, :only => [:new, :create]

  def new
    session.clear
  end

  def create
    login = params[:session]
    team = Team.authenticate(login[:name], login[:password])
    if team
      session[:team_id] = team.id
      session[:captain_id] = team.captain.id
      member = team.non_captains.first
      session[:member_id] = member.id if member
      redirect_to :controller => :verifications, :action => :edit, :id => team.id
    else
      flash.now[:alert] = "Your login failed. Have you registered? If not, start the Registration Wizard below. If you have already registered, please retype your Team Name and Password and click the Log In button again."
      render 'new'
    end
  end

  def destroy
    sesson.clear
  end
end
