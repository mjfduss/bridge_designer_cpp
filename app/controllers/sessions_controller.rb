class SessionsController < ApplicationController

  # Disable check session because this is where we get one!
  skip_before_filter :require_valid_session, :only => [:new, :create, :password_reset]

  # Disable check schedule because this is where it redirects!
  skip_before_filter :check_schedule

  def new
    clear_session_except_flash
  end

  def create
    reset_session unless session[:admin_id ]# An attack precaution.
    team = Team.authenticate(params[:session][:name], params[:session][:password])
    if team
      establish_session(team)
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

  def password_reset
    pr = PasswordReset.find_by_key(params[:key])
    if pr
      establish_session(pr.team)
      pr.delete
      session[:password_reset] = true
      redirect_to :controller => :team_completions, :action => :edit
    else
      flash[:alert] = 'Your reset message is no longer valid. Request a fresh one and try again.'
      redirect_to :controller => :sessions, :action => :new
    end
  end

  def destroy
    reset_session
    render 'new'
  end

  private

  def clear_session_except_flash
    [:team_id, :captain_id, :member_id, :login, :last_touch, :is_semis_session, :password_reset].each do |key|
      session.delete(key)
    end
  end

  def establish_session(team)
    session[:team_id] = team.id
    session[:captain_id] = team.captain.id
    member = team.non_captains.first
    session[:member_id] = member.id if member
    do_login
  end
end
