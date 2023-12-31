class CaptainCompletionsController < ApplicationController

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
        controller = Member.find(session[:member_id]).coppa? ? :coppa_member_completions : :member_completions
        redirect_to :controller => controller, :action => :edit
      end
    else
      render 'edit'
    end
  end
end
