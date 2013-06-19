class StandingsController < ApplicationController

  skip_before_filter :require_valid_session
  before_filter :require_valid_category

  caches_page :show

  ROUTE_ID_TO_CATEGORY = {
    'combined' => 'c',
    'uskids' => 'e',
    'open' => 'i',
    'semifinal' => '2'
  }
  CATEGORY_TO_ROUTE_ID = ROUTE_ID_TO_CATEGORY.invert

  def show
    @scoreboard = Scoreboard.get_current ROUTE_ID_TO_CATEGORY[params[:id]]
  end

  private

  def require_valid_category
    unless ROUTE_ID_TO_CATEGORY[params[:id]]
      kill_session 'The standings page you requested does not exist.'
    end
  end
end
