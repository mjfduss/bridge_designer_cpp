class Admin::TeamsReviewsController < Admin::ApplicationController

  def edit
  end

  def update
    if !params[:process].blank?
      params.each_pair do |key, val|
          /^(\d+)_([a-zA-Z0-9]+)$/.match(key) do |m|
            id = m[1].to_i
            case m[2]
              when 'group'
                Team.find(id).update_attribute(:group_id, val) if val != params["#{id}_group_in"]
              when 'status'
                Team.find(id).update_attributes(:status => val) if val != params["#{id}_status_in"]
            end
          end
      end
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @teams = Team.get_top_teams(@category, @standings_cutoff)
      @visible_attributes = params[:visible_attributes] || []
      @groups = Group.all
      render :action => :edit
    elsif !params[:retrieve].blank?
      redirect_to :controller => :initials, :action => :new
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
