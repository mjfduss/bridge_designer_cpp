class TeamCompletionsController < ApplicationController

  def edit
    @team = Team.find(params[:id])
    @captain = @team.captain
    @member = @team.non_captains.first
  end

  def update
    @team = Team.find(params[:id])
    @captain = @team.captain
    @member = @team.non_captains.first
    if params.has_key? :change_password
      @team.update_attribute(:password_digest, '')
      render 'edit'
    elsif params.has_key? :cancel
      redirect_to :controller => :captain_completions, :action => :edit, :id => @captain.id
    else
      @team.completed = true
      if @team.update_attributes(params[:team])
        redirect_to :controller => :homes, :action => :edit, :id => @team.id
      else
        # Cause the password box to be drawn if something was wrong there.
        if @team.password_digest
          @team.password_digest.clear if @team.errors[:password] or @team.errors[:password_confirmation]
        end
        render 'edit'
      end
    end
  end
end