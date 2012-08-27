class TeamsController < ApplicationController

  def index
  end

  def new
    @team = Team.new
    @team.captain = Member.new
  end

  def create
    @team = Team.new(params[:team])
    captain = Member.new(params[:team][:member])
    captain_ok = captain.save
    @team.captain = captain
    team_ok = @team.save
    if captain_ok && team_ok
      session[:team_id] = @team._id
      redirect_to :controller => :members, :action => :new
    else
      @team.errors.merge! captain.errors
      captain.delete
      @team.delete
      render 'new'
    end
  end

  def edit
    @team = Team.find(params[:id])
    render 'new'
  end

  def update
    @team = Team.find(params[:id])
    captain_ok = @team.captain.update_attributes(params[:team][:member])
    team_ok = @team.update_attributes(params[:team])
    if captain_ok && team_ok
      if session[:member_id]
        redirect_to :controller => :members, :action => :edit, :id => session[:member_id]
      else
        redirect_to :controller => :members, :action => :new
      end
    else
      render 'edit'
    end
  end

  def destroy
  end

end
