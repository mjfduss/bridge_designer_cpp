class Admin::MainsController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:check_servers].blank?
       redirect_to :controller => :server_statuses, :action => :edit
    end
  end

end
