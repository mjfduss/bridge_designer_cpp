class CoppaMemberCompletionsController < ApplicationController

  def edit
    @member = Member.find(session[:member_id])
    @parent = @member.parent || Parent.new
  end

  def update
    if params.has_key? :cancel
      controller = Member.find(session[:captain_id]).coppa? ? :coppa_captain_completions : :captain_completions
      redirect_to :controller => controller, :action => :edit
    else
      @member = Member.find(session[:member_id])
      @parent = @member.parent || @member.build_parent
      if @parent.update_attributes(params[:parent])
        redirect_to :controller => :team_completions, :action => :edit
      else
        render 'edit'
      end
    end
  end

end
