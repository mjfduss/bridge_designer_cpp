class StandingsLocalController < ApplicationController

  skip_before_filter :require_valid_session
  before_filter :set_cache_buster

  # TODO Uncomment me.  For debugging only.
  #caches_page :show

  def show
    code = params[:code].upcase
    @local_contest = LocalContest.find_by_code code
    if @local_contest
      @scoreboard = Team.get_local_contest_scoreboard code, params[:page]
    else
      flash[:alert] = 'The local contest standings page you requested does not exist.'
      redirect_to :controller => :sessions, :action => :new
    end
  end

  private

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
