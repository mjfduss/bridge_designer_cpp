class Admin::LocalContestTeamsController < Admin::ApplicationController

  def edit
  end

  def update
    if params.nonblank? :process
      update_modified_teams
      fetch_params
      @groups = Group.all
      render :action => :edit
    elsif params.nonblank? :download
      fetch_params(nil)
      send_data Team.format_csv(@teams, @visible_attributes), :filename => "#{@local_contest_code}_teams.csv", :type => Mime::CSV
    else
      redirect_to :controller => :initials, :action => :new
    end
  end

  private

  def fetch_params(limit = :none)
    @standings_cutoff = params[:standings_cutoff].to_i
    @visible_status = params[:visible_status] || []
    @visible_attributes = params[:visible_attributes] || []
    @local_contest_code = params[:local_contest_code].strip.upcase
    @teams = Team.assign_unofficial_ranks(LocalContest.get_teams(@local_contest_code, @visible_status,
                                          limit == :none ? @standings_cutoff : limit))
  end
end
