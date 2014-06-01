class Admin::ApplicationController < ActionController::Base

  force_ssl

  layout 'admin/application'

  protect_from_forgery
  before_filter :add_no_cache_headers, :require_valid_session

  protected

  # Check for team review controls that have changed from their initial
  # value and update only those records.  Several controllers use it.
  # Returns a pair of lists: newly qualified and disqualified teams
  def update_modified_teams
    qualified = []
    disqualified = []
    params.each_pair do |key, val|
      /^(\d+)_([a-zA-Z0-9]+)$/.match(key) do |m|
        id = m[1]
        attr = m[2]
        case attr
          when 'group'
            Team.update_all({:group_id => val == '-' ? nil : val.to_i}, {:id => id}) unless val == params["#{id}_group_in"]
          when 'status'
            old_val = params["#{id}_status_in"]
            unless val == old_val
              Team.update_all({:status => val}, {:id => id})
              # Adjust the REDIS unofficial standings.
              team = Team.find(id)
              if val == 'r'
                Standing.delete(team)
              else
                Standing.insert(team, team.best_qualifying_design) if team.best_qualifying_design
              end
              # Make lists of changes for later processing
              disqualified << team if old_val != 'r' && val == 'r'
              qualified << team if ! Team::STATUS_ACCEPTED.include?(old_val) && Team::STATUS_ACCEPTED.include?(val)
            end
        end
      end
    end
    [qualified, disqualified]
  end

  def kill_session(msg)
    # The flash is lost by resetting the session, so reset first.
    reset_session
    flash[:alert] = msg
    redirect_to :controller => :sessions, :action => :new
  end

  private

  def require_valid_session
    kill_session("You don't have a valid session.") unless session[:admin_id]
  end

  def add_no_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end