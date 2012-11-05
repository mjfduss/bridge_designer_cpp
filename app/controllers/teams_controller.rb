class TeamsController < ApplicationController

  skip_before_filter :require_valid_session, :only => [:new, :create]

  def index
  end

  def new
    @team = Team.new
    @team.captain = Member.new
  end

  def create
    @team = Team.create(params[:team])
    # Fill in rank of nested captain member, since form doesn't provide it.
    @team.members[0].rank = 0
    if @team.save
      session[:team_id] = @team.id
      session[:captain_id] = @team.members[0].id
      redirect_to :controller => :members, :action => :new
    else
      flash[:error] = "Could not save your team. Close your browser and try again."
      render 'new'
    end
  end

  def edit
    @team = Team.find(session[:team_id])
    render 'new'
  end

  def update
    @team = Team.find(session[:team_id])
    if @team.update_attributes(params[:team])
      if session[:member_id]
        redirect_to :controller => :members, :action => :edit, :id => session[:member_id]
      else
        redirect_to :controller => :members, :action => :new
      end
    else
      render 'new'
    end
  end

  def destroy
  end

end
