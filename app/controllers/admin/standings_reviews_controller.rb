class Admin::StandingsReviewsController < Admin::ApplicationController
  def edit
    @scoreboard = Team.get_scoreboard(params[:team_category], params[:standings_cutoff].to_i)
  end

  def update
  end
end
