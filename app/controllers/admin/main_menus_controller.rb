class Admin::MainMenusController < Admin::ApplicationController

  # Fields in the main menu persisted in the Administrator table.
  SESSION_STATE_FIELDS = [
      :team_category,
      :review_category,
      :standings_options,
      :posted_category,
      :team_name_likeness,
      :find_category,
      :local_contest_filter,
      :min_teams,
      :group_filter,
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
    admin.update_attribute(:session_state, params.slice(*SESSION_STATE_FIELDS).to_json)
    if !params[:check_servers].blank?
      redirect_to :controller => :server_statuses, :action => :edit
    elsif !params[:change_password].blank?
      @admin = Administrator.find(session[:admin_id])
      render :template => 'admin/password_changes/edit'
    elsif !params[:get_team_review].blank?
      @category = params[:team_category]
      @standings_cutoff = params[:standings_cutoff].to_i
      @visible_status = params[:visible_status] || []
      @visible_attributes = params[:visible_attributes] || []
      @teams = Team.get_top_teams(@category, @visible_status, @standings_cutoff)
      @groups = Group.all
      render :template => 'admin/teams_reviews/edit'
    elsif !params[:get_groups].blank?
      @edited_group = Group.new
      @filter = params[:group_filter]
      @groups = Group.fetch @filter
      render :template => 'admin/groups/edit'
    elsif !params[:get_standings_review].blank?

    elsif !params[:get_posted_standings].blank?

    elsif !params[:get_any_team].blank?
    elsif !params[:get_local_contests].blank?
      @edited_local_contest = LocalContest.new
      @min_teams = params[:min_teams].to_i
      @filter =  params[:local_contest_filter]
      @local_contests = LocalContest.fetch(@filter, @min_teams)
      render :template => 'admin/local_contests/edit'
    else
      flash.now[:alert] = "Unknown function menu function."
      render :template => 'admin/initials/new'
    end
  end

end
