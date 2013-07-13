class Admin::MainMenusController < Admin::ApplicationController

  # Fields in the main menu persisted in the Administrator table.
  SESSION_STATE_FIELDS = [
      :team_category,
      :review_category,
      :diff_review,
      :standings_options,
      :posted_category,
      :team_name_likeness,
      :find_category,
      :local_contest_code,
      :mail_teams,
      :standings_cutoff,
      :visible_attributes,
      :visible_status,
  ]

  def edit
    admin = Administrator.find(session[:admin_id])
    @state = admin && admin.session_state ? ActiveSupport::JSON.decode(admin.session_state) : {}
  end

  def update
    admin = Administrator.find(session[:admin_id])
    admin.update_attribute(:session_state, params.slice(*SESSION_STATE_FIELDS).to_json) if admin
    if params.nonblank? :check_servers
      redirect_to :controller => :server_statuses, :action => :edit
    elsif params.nonblank? :change_password
      @admin = admin
      render :template => 'admin/password_changes/edit'
    elsif params.nonblank? :log_out
      kill_session('Logged out.')
    elsif params.nonblank? :get_team_review
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @teams = Team.assign_top_ranks(Team.get_top_teams(@category, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/teams_reviews/edit'
    elsif params.nonblank? :get_groups
      redirect_to :controller => :groups, :action => :edit
    elsif params.nonblank? :get_docs
      redirect_to :controller => :html_documents, :action => :edit
    elsif params.nonblank? :get_standings_review
      @scoreboard = Team.get_scoreboard(params[:review_category], params[:standings_cutoff].to_i, params[:standings_options])
      @scoreboard.save(session[:admin_id])
      # If diff was requested, replace with the diff whenever a current scoreboard exists.
      if params[:diff_review]
        sb_old = Scoreboard.get_current params[:review_category]
        @scoreboard = Team.scoreboard_diff(sb_old, @scoreboard) unless sb_old.nil?
      end
      render :template => 'admin/standings_reviews/edit'
    elsif params.nonblank? :get_posted_standings
      @scoreboard = Scoreboard.get_current params[:posted_category]
      render :template => 'standings/show'
    elsif params.nonblank? :get_any_team
      @category = params[:find_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @team_name_likeness = params[:team_name_likeness]
      @teams = Team.assign_unofficial_ranks(Team.get_teams_by_name(@team_name_likeness, @category, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/any_teams/edit'
    elsif params.nonblank? :get_local_contests
      redirect_to :controller => :local_contests, :action => :edit
    elsif params.nonblank? :get_local_contest_teams
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @local_contest_code = params[:local_contest_code].strip.upcase
      @teams = Team.assign_unofficial_ranks(LocalContest.get_teams(@local_contest_code, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/local_contest_teams/edit'
    elsif params.nonblank? :edit_schedule
      redirect_to :controller => :schedules, :action => :edit
    elsif params.nonblank? :get_bulk_notice_menu
      redirect_to :controller => :bulk_notices, :action => :edit
    else
      flash.now[:alert] = "Unknown menu function."
      render :template => 'admin/initials/new'
    end
  end

end
