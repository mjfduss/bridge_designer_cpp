class SessionsController < ApplicationController

  # Disable check session because this is where we get one!
  skip_before_filter :require_valid_session, :only => [:new, :create]

  # Disable check schedule because this is where it redirects!
  skip_before_filter :check_schedule

  def new
  end

  def create
    reset_session # Make sure we're starting fresh. Should not be needed if we're thorough elsewhere.
    team = Team.authenticate(params[:session][:name], params[:session][:password])
    if team
      session[:team_id] = team.id
      session[:captain_id] = team.captain.id
      member = team.non_captains.first
      session[:member_id] = member.id if member
      do_login
      if team.semifinalist? && @schedule_state <= Schedule::STATE_SEMIS
        redirect_to :controller => :semi_final_instructions, :action => :edit
      else
        redirect_to :controller => :verifications, :action => :edit
      end
    else
      flash.now[:alert] = 'Your login failed. Use the Registration Wizard below or try logging in again.'
      render 'new'
    end
  end

  def destroy
    reset_session
    render 'new'
  end
end
