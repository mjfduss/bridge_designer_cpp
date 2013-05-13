class ApplicationController < ActionController::Base
  protect_from_forgery
  helper ApplicationHelper
  before_filter :require_valid_session

  private

  def broken_session
    flash[:alert] = "You don't have a valid session. Please log in or start the Registration Wizard."
    redirect_to :controller => :sessions, :action => :new
  end

  def require_valid_session
    broken_session unless session[:team_id] and session[:captain_id]
  end
end
