class SessionsController < ApplicationController

  skip_before_filter :require_valid_session, :only => [:new, :create]

  def new
    session.delete(:team_id)
  end

  def create
    login = params[:session]
    team = Team.authenticate(login[:name], login[:password])
    if team
      session[:team_id] = team.id
      session[:captain_id] = team.captain.id
      member = team.non_captains.first
      session[:member_id] = member.id if member
      redirect_to :controller => :verifications, :action => :edit
    else
      flash.now[:alert] = "Your login failed. If you haven't registered, ' +
        'start the Registration Wizard below. Otherwise try to Log In again."
      render 'new'
    end
  end

  def destroy
    session.clear
    render 'new'
  end
end
