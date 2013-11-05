class CoppaCaptainCompletionsController < ApplicationController

  def edit
    @member = Member.find(session[:captain_id])
  end

  def update
    @member = Member.find(session[:captain_id])
    # Cause all validations to occur.
    @member.completed = true
    if @member.update_attributes(params[:member])
      if session[:member_id].nil?
        redirect_to :controller => :team_completions, :action => :edit
      else
        redirect_to :controller => :member_completions, :action => :edit
      end
    else
      render 'edit'
    end
  end

end
