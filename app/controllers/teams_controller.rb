class TeamsController < ApplicationController

  def index
  end

  def new
    @team = Team.new
    @team.captain = Member.new
  end

  def create
    @team = Team.create(params[:team])
    @team.captain = @team.members.first
    if @team.save
      session[:team_id] = @team.id
      session[:captain_id] = @team.captain.id
      redirect_to :controller => :members, :action => :new
    else
      flash[:error] = "Could not save your team. Close your browser and try again."
      render 'new'
    end
  end

  def edit
    @team = Team.find(params[:id])
    render 'new'
  end

  def update
    @team = Team.find(params[:id])
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
