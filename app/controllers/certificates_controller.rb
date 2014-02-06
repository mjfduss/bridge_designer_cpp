class CertificatesController < ApplicationController
  def show
    @team = Team.find(session[:team_id])
    if @team.best_design && %w{a 2}.include?(@team.status) && session[:admin_id]
      @standing, @basis = @team.standing
    else
      # Should never happen because link should not be presented.
      redirect_to :controller => :homes, :action => :edit
    end
  end
end
