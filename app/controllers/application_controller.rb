class ApplicationController < ActionController::Base
  protect_from_forgery
  helper ApplicationHelper
  before_filter :require_valid_session

  private

  def require_valid_session
    unless session[:team_id] and session[:captain_id]
      flash[:alert] = "You don't have a valid session.  Please log in or start the Registration Wizard."
      redirect_to :controller => :sessions, :action => :new
    end
  end
end
