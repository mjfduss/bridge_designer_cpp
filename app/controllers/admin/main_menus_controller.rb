class Admin::MainMenusController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:check_servers].blank?
      redirect_to :controller => :server_statuses, :action => :edit
    elsif !params[:change_password].blank?
      @admin = Administrator.find(session[:admin_id])
      render :template => 'admin/password_changes/edit'
    elsif !params[:get_team_review].blank?
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @teams = Team.get_top_teams(@category, @standings_cutoff)
      @groups = Group.all
      @visible_attributes = params[:visible_attributes] || []
      render :template => 'admin/teams_reviews/edit'
    elsif !params[:get_groups].blank?
      @edited_group = Group.new
      @groups = Group.all
      render :template => 'admin/groups/edit'
    elsif !params[:get_standings_review].blank?

    elsif !params[:get_posted_standings].blank?

    elsif !params[:get_any_team].blank?
    elsif !params[:get_local_contests].blank?
      @edited_local_contest = LocalContest.new
      @local_contests = LocalContest.all
      render :template => 'admin/local_contests/edit'
    else
      flash.now[:alert] = "Unknown function menu function."
      render :template => 'admin/initials/new'
    end
  end

end
