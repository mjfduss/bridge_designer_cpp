class Admin::ApplicationController < ActionController::Base

  layout 'admin/application'

  protect_from_forgery
  before_filter :require_valid_session

  private

  def require_valid_session
    unless session[:admin_id]
      logger.error "No session: #{params}"
      flash[:alert] = "You don't have a valid session."
      redirect_to :controller => :sessions, :action => :new
    end
  end
end