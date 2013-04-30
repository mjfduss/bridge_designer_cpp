class Admin::ApplicationController < ActionController::Base

  layout 'admin/application'

  protect_from_forgery
  before_filter :require_valid_session

  protected

  # Check for controls that have changed from their initial value and update only those records.
  def update_modified_teams
    params.each_pair do |key, val|
      /^(\d+)_([a-zA-Z0-9]+)$/.match(key) do |m|
        id = m[1].to_i
        team = Team.find(id)
        if team
          case m[2]
            when 'group'
              team.update_attribute(:group_id, val) if val != params["#{id}_group_in"]
            when 'status'
                team.update_attributes(:status => val) if val != params["#{id}_status_in"]
                if val == 'r'
                  Standing.delete(team)
                else
                  Standing.insert(team, team.best_design) if team.best_design
                end
          end
        end
      end
    end
  end

  private

  def require_valid_session
    unless session[:admin_id]
      logger.error "No session: #{params}"
      flash[:alert] = "You don't have a valid session."
      redirect_to :controller => :sessions, :action => :new
    end
  end
end