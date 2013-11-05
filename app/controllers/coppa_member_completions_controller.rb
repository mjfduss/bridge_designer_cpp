class CoppaMemberCompletionsController < ApplicationController

  def edit
    @member = Member.find(session[:member_id])
  end

  def update
    @member = Member.find(session[:member_id])
    if params.has_key? :cancel
      redirect_to :controller => :captain_completions, :action => :edit
    else
      # Cause all validations to occur.
      @member.completed = true
      if @member.update_attributes(params[:member])
        redirect_to :controller => :team_completions, :action => :edit
      else
        render 'edit'
      end
    end
  end

end
