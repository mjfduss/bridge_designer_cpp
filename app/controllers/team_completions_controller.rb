class TeamCompletionsController < ApplicationController

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
    if @team.password_digest.blank? or session[:password_reset]
      @team.completion_status = :pending_new_password
      session.delete :password_reset
    end
  end

  def update
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
    @team.completion_status = :pending_new_password if @team.password_digest.blank?
    if params.nonblank? :change_password
      @team.completion_status = :pending_new_password
      render 'edit'
    elsif params.has_key? :cancel
      controller = @captain.coppa? ? :coppa_captain_completions : :captain_completions
      redirect_to :controller => controller, :action => :edit
    elsif params.has_key? :update
      if do_update
        @team.new_local_contest = nil if @team.errors[:new_local_contest].blank?
      else
        @team.completion_status = :pending_new_password if params[:team].has_key? :password        
      end
      render 'edit'
    else
      if do_update
        do_login
        redirect_to :controller => :homes, :action => :edit
      else
        # Keep the password fields open if they already are
        @team.completion_status = :pending_new_password if params[:team].has_key? :password
        render 'edit'
      end
    end
  end

private
  
  def do_update

    # Clobber any deleted local contest affiliations
    if params[:deleted_affiliations]
      @team.affiliations.each do |a|
        Affiliation.delete(a.id) if params[:deleted_affiliations].include? a.local_contest.code
      end
    end

    # Set a status flag in the model to govern validation
    @team.completion_status = params[:team].has_key?(:password) ? :complete_with_fresh_password : :complete_with_old_password

    # Fill in registration fields if the team is not already registered
    @team.register

    # Validate, save with new team params and log in if not already done.
    @team.update_attributes(params[:team])
  end
end
