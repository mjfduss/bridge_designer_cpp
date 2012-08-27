class MembersController < ApplicationController
  def index
  end

  def new
    @member = Member.new
    @member.team = Team.new
  end

  def create
    if params.has_key? :cancel
      redirect_to :controller => :teams, :action => :edit, :id => session[:team_id]
    elsif params.has_key? :skip
      redirect_to :controller => :certifications, :action => :new
    else
      @member = Member.new(params[:team][:member])
      @member.team = Team.find(session[:team_id])
      if @member.save 
        session[:member_id] = @member._id;
        redirect_to :controller => :certifications, :action => :new
      else
        render 'new'
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
      redirect_to :controller => :certifications, :action => :new
    else
      @member = Member.find(params[:id])
      if @member.update_attributes(params[:team][:member])
        redirect_to :controller => :certifications, :action => :new      
      else
        render 'edit'
      end
    end
  end

end
