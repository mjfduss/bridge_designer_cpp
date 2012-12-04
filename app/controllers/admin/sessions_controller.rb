class Admin::SessionsController < Admin::ApplicationController

  skip_before_filter :require_valid_session, :only => [:new, :create]

  def new
    session.clear
  end

  def create
    admin = Administrator.authenticate(params[:session][:login], params[:session][:password])
    if admin
      session[:admin_id] = admin.id
      redirect_to :controller => :mains, :action => :edit
    else
      flash.now[:alert] = "Your login failed."
      render 'new'
    end
  end

  def destroy
    session.clear
    render 'new'
  end
end
