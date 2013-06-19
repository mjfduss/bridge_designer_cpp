class MembersController < ApplicationController

  def new
    @member = Member.new
  end

  def create
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit
    elsif params.has_key? :skip
      redirect_to :controller => :certifications, :action => :edit
    else
      @member = Member.new(params[:member])
      # Fill in rank of member record, since it is not a user field.
      @member.rank = 1
      @member.team = Team.find(session[:team_id])
      if @member.save 
        session[:member_id] = @member.id;
        redirect_to :controller => :certifications, :action => :edit
      else
        kill_session 'Could not save new member record.'
      end
    end
  end

  def edit
    @member = Member.find(session[:member_id])
    render 'new'
  end

  def update
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit
    elsif params.has_key? :skip
      Member.delete(session[:member_id])
      session.delete(:member_id)
      redirect_to :controller => :certifications, :action => :edit
    else
      @member = Member.find(session[:member_id])
      if @member.update_attributes(params[:member])
        redirect_to :controller => :certifications, :action => :edit
      else
        kill_session 'Could not save new value for existing member record.'
      end
    end
  end

end
