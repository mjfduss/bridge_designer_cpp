class MemberCompletionsController < ApplicationController

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
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
