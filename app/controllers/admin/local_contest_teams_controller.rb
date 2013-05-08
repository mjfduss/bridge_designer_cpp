class Admin::LocalContestTeamsController < ApplicationController
  def edit
  end

  def update
    if !params[:process].blank?
      update_modified_teams
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @local_contest_code = params[:local_contest_code]
      @teams = LocalContest.get_teams(@local_contest_code, @category, @visible_status, @standings_cutoff)
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
