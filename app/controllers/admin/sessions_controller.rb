class Admin::SessionsController < Admin::ApplicationController

  layout 'admin/login'  # Special layout that removes any enclosing frames.

  skip_before_filter :require_valid_session, :only => [:new, :create]

  def new
  end

  def create
    reset_session
    admin = Administrator.authenticate(params[:session][:login], params[:session][:password])
    if admin
      session[:admin_id] = admin.id
      redirect_to :controller => :frames, :action => :new
    else
      flash.now[:alert] = 'Your login failed.'
      render 'new'
    end
  end

  def destroy
    reset_session
    render 'new'
  end

end