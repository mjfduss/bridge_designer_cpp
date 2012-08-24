class MembersController < ApplicationController
  def index
  end

  def new
    @member = Member.new
  end

  def create
    if params.has_key? :cancel
      logger.debug "Cancel Member"
      redirect_to :controller => :teams, :action => :edit, :id => session[:id]
    else
      @member = Member.new(params[:member][:member])
      @member.team = Team.find(session[:id])
      if @member.save 
        redirect_to :controller => :certifications, :action => :new
      else
        render 'new'
      end
    end
  end

  def edit
  end

  def update
  end
end
