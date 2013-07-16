class Admin::ApplicationController < ActionController::Base

  layout 'admin/application'

  protect_from_forgery
  before_filter :require_valid_session

  def disqualified
    @disqualified ||= []
  end

  def disqualified=(val)
    @disqualified = val
  end

  def qualified
    @qualified ||= []
  end

  def qualified=(val)
    @qualified = val
  end

  protected

  # Check for team review controls that have changed from their initial
  # value and update only those records.  Several controllers use it.
  def update_modified_teams
    params.each_pair do |key, val|
      /^(\d+)_([a-zA-Z0-9]+)$/.match(key) do |m|
        id = m[1]
        attr = m[2]
        case attr
          when 'group'
            Team.update_all({:group_id => val}, {:id => id}) unless val == params["#{id}_group_in"]
          when 'status'
            old_val = params["#{id}_status_in"]
            unless val == old_val
              Team.update_all({:status => val}, {:id => id})
              # Adjust the REDIS unofficial standings.
              team = Team.find(id)
              if val == 'r'
                Standing.delete(team)
              else
                Standing.insert(team, team.best_design) if team.best_design
              end
              # Make lists of changes for later processing
              disqualified << team if old_val != 'r' && val == 'r'
              qualified << team if ! %w{a 2}.include?(old_val) && %w{a 2}.include?(val)
            end
        end
      end
    end
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

end