class StandingsLocalController < ApplicationController

  skip_before_filter :require_valid_session

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
    expires_in 1, :public => true
  end
end
