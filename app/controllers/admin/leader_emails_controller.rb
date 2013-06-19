class Admin::LeaderEmailsController < Admin::ApplicationController
  def edit
    Team.get_top_teams
    @emails = Matrix.build()
  end

  def update
  end
end
