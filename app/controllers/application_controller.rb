class ApplicationController < ActionController::Base
  protect_from_forgery
  helper ApplicationHelper
  before_filter :require_valid_session

  protected

  def require_team_post
    broken_session unless params[:id].blank? || params[:id].to_s == session[:team_id].to_s
  end

  def require_captain_post
    broken_session unless params[:id].blank? || params[:id].to_s == session[:captain_id].to_s
  end

  def require_member_post
    broken_session unless params[:id].blank? || params[:id].to_s == session[:member_id].to_s
  end

  private

  def broken_session
    flash[:alert] = "You don't have a valid session. Please log in or start the Registration Wizard."
    redirect_to :controller => :sessions, :action => :new
  end

  def require_valid_session
    broken_session unless session[:team_id] and session[:captain_id]
  end
end
