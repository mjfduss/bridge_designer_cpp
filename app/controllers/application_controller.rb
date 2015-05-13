class ApplicationController < ActionController::Base
  protect_from_forgery
  helper ApplicationHelper
  before_filter :add_no_cache_headers, :require_valid_session, :load_schedule, :check_schedule

  attr_reader :schedule, :schedule_state

  protected

  def do_login
    session[:login] = Time.now unless session[:login]
  end

  def require_login
    kill_session("Your session was not logged in.  Please log in again.") unless session[:login]
  end

  private

  def load_schedule
    @schedule = Schedule.fetch_cache
    # We look up the state and store it for the controller run so it can't change in the middle!
    # If we have an admin session, we are in quals or semis ()after quals are over) for test uploads.
    @schedule_state = if !session.has_key?(:admin_id)
                        @schedule.state
                      elsif @schedule.state >= Schedule::STATE_QUALS_CLOSED
                        Schedule::STATE_SEMIS
                      else
                        Schedule::STATE_QUALS
                      end
  end

  def kill_session(msg)
    # The flash is lost by resetting the session, so reset first.
    reset_session
    flash[:alert] = msg
    redirect_to :controller => :sessions, :action => :new
  end

  def check_schedule
    # Punt if the system should be closed.
    if Schedule::STATES_CLOSED_FOR_LOGIN.include? @schedule_state
      kill_session 'The Contest is currently closed.'
    elsif session[:is_semis_session] && @schedule_state < Schedule::STATE_SEMIS_PREREG
      kill_session "We've logged you out because Semi-Finals are not yet in progress!"
    elsif session[:is_semis_session] && @schedule_state > Schedule::STATE_SEMIS
      kill_session "We've logged you out because Semi-Finals are over!"
    end
  end

  def require_valid_session
    unless session[:team_id] and session[:captain_id]
      kill_session 'Your session is invalid. Please log in or start the Registration Wizard.'
    else
      # Expire if the user hasn't touched the session for a while.
      now = Time.now
      last_touch = session[:last_touch]
      if last_touch and last_touch < 10.minutes.ago(now)
        kill_session "We've logged you out for your own safety. Please log in again!"
      else
        session[:last_touch] = now
      end
    end
  end

  def add_no_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
