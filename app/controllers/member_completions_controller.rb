class MemberCompletionsController < ApplicationController

  before_filter :require_member_post

  def edit
    @member = Member.find(session[:member_id])
  end

  def update
    @member = Member.find(session[:member_id])
    if params.has_key? :cancel
      redirect_to :controller => :captain_completions, :action => :edit, :id => session[:captain_id]
    else
      # Cause all validations to occur.
      @member.completed = true
      if @member.update_attributes(params[:member])
        redirect_to :controller => :team_completions, :action => :edit, :id => session[:team_id]
      else
        render 'edit'
      end
    end
  end
end
