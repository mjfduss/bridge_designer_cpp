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
      @teams = Team.assign_top_ranks(Team.get_top_teams(@category, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :action => :edit
    elsif !params[:retrieve].blank?
      render :controller => :retrieve_designs, :action => :edit
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
