class Admin::TeamsReviewsController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:process].blank?
      update_modified_teams
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @teams = Team.get_top_teams(@category, @visible_status, @standings_cutoff)
      Team.assign_top_ranks(@teams)
      @groups = Group.all
      render :action => :edit
    elsif !params[:retrieve].blank?
      redirect_to :controller => :retrieve_designs, :action => :new
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
