class Admin::AnyTeamsController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:process].blank?
      update_modified_teams
      @category = params[:find_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @team_name_likeness = params[:team_name_likeness]
      @teams = Team.get_teams_by_name(@team_name_likeness, @category, @visible_status, @standings_cutoff)
      Team.assign_unofficial_ranks(@teams)
      @groups = Group.all
      render :action => :edit
    elsif !params[:retrieve].blank?
      redirect_to :controller => :retrieve_designs, :action => :new
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
