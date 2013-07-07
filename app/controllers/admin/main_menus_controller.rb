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
    if !params[:check_servers].blank?
      redirect_to :controller => :server_statuses, :action => :edit
    elsif !params[:change_password].blank?
      @admin = admin
      render :template => 'admin/password_changes/edit'
    elsif !params[:log_out].blank?
      kill_session('Logged out.')
    elsif !params[:get_team_review].blank?
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @teams = Team.assign_top_ranks(Team.get_top_teams(@category, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/teams_reviews/edit'
    elsif !params[:get_groups].blank?
      redirect_to :controller => :groups, :action => :edit
    elsif !params[:get_docs].blank?
      redirect_to :controller => :documents, :action => :new
    elsif !params[:get_standings_review].blank?
      @scoreboard = Team.get_scoreboard(params[:review_category], params[:standings_cutoff].to_i, params[:standings_options])
      @scoreboard.save(session[:admin_id])
      # If diff was requested, replace with the diff whenever a current scoreboard exists.
      if params[:diff_review]
        sb_old = Scoreboard.get_current params[:review_category]
        @scoreboard = Team.scoreboard_diff(sb_old, @scoreboard) unless sb_old.nil?
      end
      render :template => 'admin/standings_reviews/edit'
    elsif !params[:get_posted_standings].blank?
      @scoreboard = Scoreboard.get_current params[:posted_category]
      render :template => 'standings/show'
    elsif !params[:get_any_team].blank?
      @category = params[:find_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @team_name_likeness = params[:team_name_likeness]
      @teams = Team.assign_unofficial_ranks(Team.get_teams_by_name(@team_name_likeness, @category, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/any_teams/edit'
    elsif !params[:get_local_contests].blank?
      redirect_to :controller => :local_contests, :action => :edit
    elsif !params[:get_local_contest_teams].blank?
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @local_contest_code = params[:local_contest_code].strip.upcase
      @teams = Team.assign_unofficial_ranks(LocalContest.get_teams(@local_contest_code, @visible_status, @standings_cutoff))
      @groups = Group.all
      render :template => 'admin/local_contest_teams/edit'
    elsif !params[:leader_emails].blank?
      @standings_cutoff = params[:standings_cutoff].to_i
      render :template => 'admin/leader_emails/edit'
    elsif !params[:edit_schedule].blank?
      redirect_to :controller => :schedules, :action => :edit
    else
      flash.now[:alert] = "Unknown menu function."
      render :template => 'admin/initials/new'
    end
  end

end
