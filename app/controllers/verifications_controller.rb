class VerificationsController < ApplicationController
  def edit
    @team = Team.find(session[:team_id])
  end

  def update
  end
end
