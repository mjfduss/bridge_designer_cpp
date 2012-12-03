class Admin::MainsController < ApplicationController

  layout 'admin'

  def edit
  end

  def update
    if !params[:check_servers].blank?
       redirect_to :controller => :server_statuses, :action => :edit
    end
  end

end
