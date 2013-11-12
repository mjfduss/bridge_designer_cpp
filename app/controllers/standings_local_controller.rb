class StandingsLocalController < ApplicationController

  skip_before_filter :require_valid_session

  def show
    code = params[:code].upcase
    @local_contest = LocalContest.find_by_code code
    if @local_contest
      @scoreboard = LocalScoreboard.for_code(code, params[:page])
    else
      flash[:alert] = 'The local contest standings page you requested does not exist.'
      redirect_to :controller => :sessions, :action => :new
    end
  end
end
