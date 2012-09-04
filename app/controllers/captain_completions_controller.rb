class CaptainCompletionsController < ApplicationController

  def new
    @member = Team.find(session[:team_id]).captain
  end

  def create
    @member = Team.find(session[:team_id]).captain
  end

  def edit
  end

  def update
  end
end
