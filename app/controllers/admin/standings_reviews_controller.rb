class Admin::StandingsReviewsController < Admin::ApplicationController

  def edit
  end

  def update
    sb = Scoreboard.find(params[:scoreboard_id])
    if sb
      sb.update_attribute(:status, 'p')
      # Clear old unposted scoreboards for this admin only.
      Scoreboard.delete_all(['status IS NULL and admin_id = ?', session[:admin_id]])
      id =  StandingsController::CATEGORY_TO_ROUTE_ID[params[:scoreboard_category]]
      if id
        # Expire the old standings page
        expire_page standing_path(id)
        # Get the new one and incidentally update the cache.
        redirect_to standing_path(id)
      else
        flash[:alert] = "Sorry. Posting of the scoreboard failed. Call the Judge administrator."
        redirect_to :controller => ':initials', :action => :new
      end
    else
      flash[:alert] = "Sorry. The scoreboard you approved disappeared from the server. Call the Judge administrator."
      redirect_to :controller => ':initials', :action => :new
    end
  end
end
