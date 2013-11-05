class CertificationsController < ApplicationController

  def edit
    @team = Team.find(session[:team_id])
    # This causes a bounce if we got here with back button or history.
    unless redirect_to_category_completion(@team)
      @captain = @team.captain
      @member = session[:member_id] && Member.find(session[:member_id])
    end
  end

  def update
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit
    else
      team = Team.find(session[:team_id])
      # This seals the registration category, never to be changed.
      team.update_attribute(:category, team.registration_category)
      redirect_to_category_completion(team)
    end
  end

  private

  # This falls through if the team's category is not already correctly set.
  def redirect_to_category_completion(team)
    case team.category
      when 'm', 'h'
        controller = team.captain.coppa? ? :coppa_captain_completions : :captain_completions
        redirect_to :controller => controller, :action => :edit
        true
      when 'i'
        redirect_to :controller => :team_completions, :action => :edit
        true
      else
        false
    end
  end
end
