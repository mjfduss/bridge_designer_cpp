class Admin::TeamsReviewsController < Admin::ApplicationController

  def edit
  end

  def update
    if params.nonblank? :process
      update_modified_teams
      msg = ''
      unless disqualified.empty?
        msg << 'Disqualified notices sent to ' + disqualified.map{|t| "'#{t.name}'"}.to_sentence + '. '
        disqualified.each{|t| DisqualifiedNotice.delay.to_team(t) }
      end
      unless qualified.empty?
        msg << 'Qualified notices sent to ' + qualified.map{|t| "'#{t.name}'"}.to_sentence  + '. '
        qualified.each{|t| QualifiedNotice.delay.to_team(t) }
      end
      flash[:alert] = msg unless msg.empty?
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @teams = Team.assign_top_ranks(Team.get_top_teams(@category, @visible_status, nil, @standings_cutoff))
      @groups = Group.all
      render :action => :edit
    elsif params.nonblank? :retrieve
      render :controller => :retrieve_designs, :action => :edit
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

end
