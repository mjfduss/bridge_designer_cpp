class Admin::TeamsReviewsController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:process].blank?
      params.each_pair do |key, val|
          if key.ends
      end
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @teams = Team.get_top_teams(@category, @standings_cutoff)
      @visible_attributes = params[:visible_attributes] || []
      render :action => :edit
    elsif !params[:retrieve].blank?
      redirect_to :controller => :initials, :action => :new
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
