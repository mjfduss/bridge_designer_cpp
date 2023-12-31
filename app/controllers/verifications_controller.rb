class VerificationsController < ApplicationController

  before_filter :require_login

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(session[:team_id])
    if params.has_key? :cancel
      controller = case @team.category
                     when 'h', 'm'
                       @team.captain.coppa? ? :coppa_captain_completions : :captain_completions
                     when 'i'
                       :team_completions
                   end
      redirect_to :controller => controller, :action => :edit
    else
      # No need to check registration here because we have a valid session
      # only if registration was completed.
      redirect_to :controller => :homes, :action => :edit
    end
  end
end
