class CaptainCompletionsController < ApplicationController

  before_filter :require_captain_post

  def edit
    @member = Member.find(session[:captain_id])
  end

  def update
    @member = Member.find(session[:captain_id])
    # Cause all validations to occur.
    @member.completed = true
    if @member.update_attributes(params[:member])
      if session[:member_id].nil?
        redirect_to :controller => :team_completions, :action => :edit, :id => session[:team_id]
      else
        redirect_to :controller => :member_completions, :action => :edit, :id => session[:member_id]
      end
    else
      render 'edit'
    end
  end
end
