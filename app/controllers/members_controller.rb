class MembersController < ApplicationController

  def index
  end

  def new
    @member = Member.new
  end

  def create
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    elsif params.has_key? :skip
      redirect_to :controller => :certifications, :action => :edit, :id => session[:team_id]
    else
      @member = Member.new(params[:member])
      # Fill in rank of member record, since it is not a user field.
      @member.rank = 1
      @member.team = Team.find(session[:team_id])
      if @member.save 
        session[:member_id] = @member.id;
        redirect_to :controller => :certifications, :action => :edit, :id => session[:team_id]
      else
        flash[:error] = "Could not save new member record."
        redirect_to :controller => :sessions, :action => :new
      end
    end
  end

  def edit
    @member = Member.find(params[:id])
    render 'new'
  end

  def update
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    elsif params.has_key? :skip
      session.delete(:member_id)
      Member.delete(params[:id])
      redirect_to :controller => :certifications, :action => :edit, :id => session[:team_id]
    else
      @member = Member.find(params[:id])
      if @member.update_attributes(params[:member])
        redirect_to :controller => :certifications, :action => :edit, :id => session[:team_id]   
      else
        flash[:error] = "Could not save new value for existing member record."
        redirect_to :controller => :sessions, :action => :new
      end
    end
  end

end
