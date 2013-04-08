class CertificationsController < ApplicationController

  before_filter :require_team_post

  # TODO: If we arrive here and category is already set, it's a back button, etc. Bounce to captain completion.

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = session[:member_id] && Member.find(session[:member_id])
  end

  def update
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    else
      team = Team.find(session[:team_id])
      # This seals the registration category, never to be changed.
      team.update_attribute(:category, team.registration_category)
      if team.category == 'e'
        redirect_to :controller => :captain_completions, :action => :edit, :id => team.captain.id
      else
        redirect_to :controller => :team_completions, :action => :edit, :id => team.id
      end
    end
  end
end
