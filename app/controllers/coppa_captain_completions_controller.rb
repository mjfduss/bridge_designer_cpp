class CoppaCaptainCompletionsController < ApplicationController

  def edit
    @member = Member.find(session[:captain_id])
    @parent = @member.parent || Parent.new
  end

  def update
    @member = Member.find(session[:captain_id])
    @parent = @member.parent || @member.build_parent
    if @parent.update_attributes(params[:parent])
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
