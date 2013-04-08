class Admin::MainMenusController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:get_team_review].blank?
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @teams = Team.get_top_teams(@category, @standings_cutoff)
      @visible_attributes = params[:visible_attributes] || []
      render :template => 'admin/teams_reviews/edit'
    elsif !params[:get_standings_review].blank?

    elsif !params[:get_posted_standings].blank?

    elsif !params[:get_any_team].blank?

    elsif !params[:check_servers].blank?
      redirect_to :controller => :server_statuses, :action => :edit
    end
  end

end
