class TeamCompletionsController < ApplicationController

  def edit
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
    @team.completion_status = :pending_new_password if @team.password_digest.blank?
  end

  def update
    @team = Team.find(session[:team_id])
    @captain = @team.captain
    @member = @team.non_captains.first
    @team.completion_status = :pending_new_password if @team.password_digest.blank?
    if !params[:change_password].blank?
      @team.completion_status = :pending_new_password
      render 'edit'
    elsif params.has_key? :cancel
      redirect_to :controller => :captain_completions, :action => :edit
    elsif params.has_key? :update
      if do_update
        @team.new_local_contest = nil if @team.errors[:new_local_contest].blank?
      else
        @team.completion_status = :pending_new_password if params[:team].has_key? :password        
      end
      render 'edit'
    else
      if do_update
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

    # Validate and save if good
    @team.update_attributes(params[:team])
  end
end
